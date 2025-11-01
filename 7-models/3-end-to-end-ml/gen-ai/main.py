import os, torch
import streamlit as st
import pandas as pd
from io import BytesIO
from typing import Any
from PIL import Image
from streamlit_drawable_canvas import st_canvas
from diffusers import StableDiffusionInpaintPipeline
from snowflake.snowpark.session import Session
from snowflake.snowpark.functions import col as _col

st.set_page_config(page_title="Tel Co", layout="wide", page_icon="📞")

def get_params() -> dict[str, Any]:
    if not os.path.exists("/snowflake/session/token"):
        return {
            "account": os.getenv("SNOWFLAKE_ACCOUNT"),
            "user": os.getenv("SNOWFLAKE_USER"),
            "password": os.getenv("SNOWFLAKE_PASSWORD") }

    with open("/snowflake/session/token", "r") as f:
        return {
            "account": os.getenv("SNOWFLAKE_ACCOUNT"),
            "host": os.getenv("SNOWFLAKE_HOST"),
            "authenticator": "oauth",
            "token": f.read() }

def get_session() -> Session:
    if "snowflake_session" not in st.session_state:
        session = Session.builder.configs(get_params()).create()
        st.session_state.snowflake_session = session
    return st.session_state.snowflake_session

session = get_session()

def generate_image_from_model(
    prompt: str, base_image: Image.Image, inpainted_image: Image.Image) -> None:
    pipe = get_inpainting_model()
    pipe = pipe.to("cuda")
    image = pipe(prompt=prompt, image=base_image, mask_image=inpainted_image).images[0]
    image.save("inpaint_image.png")
    st.session_state.inpainted_image = "inpaint_image.png"
    st.rerun()

def generate_image(base_image: Image.Image, inpainted_image: Any, prompt: str):
    inpainted_image_data = inpainted_image.image_data[:, :, -1] > 0
    inpainted_image = Image.fromarray(inpainted_image_data)

    try:
        generate_image_from_model(prompt, base_image, inpainted_image)
    except AssertionError:
        image = base_image
        st.session_state.inpainted_image = image

def get_inpainting_model():
    return StableDiffusionInpaintPipeline.from_pretrained(
        "stabilityai/stable-diffusion-2-inpainting",
        revision="fp16",
        torch_dtype=torch.float32)

def add_navigation():
    st.sidebar.page_link("app_main.py", label="Gen AI Inpainting", icon="🎨")
    st.sidebar.page_link("pages/unistore_hybrid_tables.py", label="Tower Uptime", icon="🏓")

add_navigation()

if "inpainted_image" not in st.session_state:
    st.session_state.inpainted_image = None

def reset_image():
    st.session_state.inpainted_image = None

@st.cache_data
def get_images() -> pd.DataFrame:
    return (session.table("IMAGES")
        .order_by(_col("ID"))
        .to_pandas()[[ "CITY_NAME", "IMAGE_BYTES" ]])

# Don't cache, to show how metadata can be updated in real time
@st.experimental_fragment(run_every=15)
def get_image_metadata(city_name: str) -> dict:
    metadata = (
        session.table("IMAGES")
        .filter(_col("CITY_NAME") == city_name)
        .to_pandas()
        .iloc[0]
        .to_dict())
    return { k: v for k, v in metadata.items() if k not in ["IMAGE_BYTES", "FILE_NAME", "LAT", "LON"] }

@st.cache_data
def get_image(city_name: str) -> Image.Image:
    images = get_images()
    image_bytes = images.loc[images["CITY_NAME"] == city_name]["IMAGE_BYTES"].values[0]
    image = Image.open(BytesIO(bytes.fromhex(image_bytes))).convert("RGB")
    return image

st.subheader(":phone: Gen AI Inpainting: Snowpark Container Services")

with open("app.css") as f:
    st.markdown(f"<style>{f.read()}</style>", unsafe_allow_html=True)

left, right = st.columns(2, gap="large")
with left:
    with st.container(border=True, height=770):
        images = get_images()
        city_name = st.selectbox(
            "Select Image",
            images["CITY_NAME"].unique(),
            on_change=reset_image,
        )
        if city_name:
            base_image = get_image(city_name)

            _, col, _ = st.columns([1, 10, 1])
            with col:
                inpainted_image = st_canvas(
                    background_image=base_image,
                    display_toolbar=False,
                    stroke_color="white",
                    stroke_width=85,
                    width=600,
                )
            data = get_image_metadata(city_name)
            _, col, _ = st.columns([1, 8, 1])
            col.dataframe(
                pd.DataFrame(data, index=[0]), hide_index=True, use_container_width=True
            )
            prompt = st.text_input(
                "Enter prompt", "Cell phone tower, high resolution, where marked"
            )
            generate_image_btn = st.button(
                "Generate Image", type="primary", use_container_width=True
            )
        else:
            # No image selected, which should never happen
            st.stop()

with right:
    if generate_image_btn:
        with st.spinner("Generating image..."):
            generate_image(base_image, inpainted_image, prompt)
    if st.session_state.inpainted_image:
        with st.container(border=True, height=770):
            _, col, _ = st.columns([1, 11, 1])
            with col:
                st.write("#### Generated Image")
                st.image(st.session_state.inpainted_image, use_container_width=True)
