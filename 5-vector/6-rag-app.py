## Tasty Bytes - RAG Chatbot Using Cortex and Streamlit (inspired from)
## https://quickstarts.snowflake.com/guide/tasty_bytes_rag_chatbot_using_cortex_and_streamlit/index.html
## copy and paste as a new Streamlit in Snowflake app, then ask questions like below

## Who is the CEO?
## What cities are trucks in?
## Do you do private events and catering?

import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.cortex import Complete
import snowflake.snowpark.functions as F

st.set_page_config(layout="wide", initial_sidebar_state="expanded")
st.title("Customer Q&A Assistant")
session = get_active_session()

if "background_info" not in st.session_state:
    st.session_state.background_info = (
        session.table("documents")
        .select("raw_text")
        .filter(F.col("relative_path") == "tasty_bytes_who_we_are.pdf")
        .collect()[0][0])

if "messages" not in st.session_state:
    st.session_state.messages = [{
        "role": "assistant",
        "content": "What question do you need assistance answering?"
    }]

if user_message := st.chat_input():
    st.session_state.messages.append(
        {"role": "user", "content": user_message})

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if st.session_state.messages[-1]["role"] != "assistant":
    with st.chat_message("assistant"):
        chat = str(st.session_state.messages[-20:]).replace("'", "")
        # st.warning(chat)
        
        summary = Complete("mistral-7b",
            f"Provide the most recent question with essential context from this support chat: {chat}")
        summary = summary.replace("'", "")
        # st.warning(summary)
        sql = f"""select input_text, source_desc,
            VECTOR_COSINE_SIMILARITY(chunk_embedding,
                SNOWFLAKE.CORTEX.EMBED_TEXT_768('e5-base-v2',
                    '{summary.replace("'", "''")}')) as dist
            from vector_store
            order by dist desc
            limit 1"""
        # st.warning(sql)
        doc = session.sql(sql).to_pandas()
        st.info("source: " + doc["SOURCE_DESC"].iloc[0])
        context = doc["INPUT_TEXT"].iloc[0]

        prompt = f"""Answer this new customer question sent to our support agent
            at Tasty Bytes Food Truck Company. Use the background information
            and provided context taken from the most relevant corporate documents
            or previous support chat logs with other customers.
            Be concise and only answer the latest question.
            The question is in the chat.
            Chat: <chat> {chat} </chat>.
            Context: <context> {context} </context>.
            Background Info: <background_info> {st.session_state.background_info} </background_info>."""
        prompt = prompt.replace("'", "")
        # st.warning(prompt)
        response = Complete("mistral-7b", prompt)
        st.markdown(response)
        
        st.session_state.messages.append(
            {"role": "assistant", "content": response})
