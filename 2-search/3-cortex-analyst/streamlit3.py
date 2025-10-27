import json, time, _snowflake
import pandas as pd
import streamlit as st
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Union
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.exceptions import SnowparkSQLException

session = get_active_session()

def process_user_input(prompt: str):

    st.session_state.warnings = []
    new_user_message = {
        "role": "user",
        "content": [{"type": "text", "text": prompt}]}
    st.session_state.messages.append(new_user_message)
    with st.chat_message("user"):
        user_msg_index = len(st.session_state.messages) - 1
        display_message(new_user_message["content"], user_msg_index)

    with st.chat_message("analyst"):
        with st.spinner("Waiting for Analyst's response..."):
            time.sleep(1)
            response = _snowflake.send_snow_api_request(
                "POST", "/api/v2/cortex/analyst/message", {}, {}, {
                    "messages": st.session_state.messages,
                    "semantic_model_file": "@test.ts.stage1/ts.yaml"
                }, None, 50000)
            if response["status"] < 400:
                analyst_message = {
                    "role": "analyst",
                    "content": response["message"]["content"],
                    "request_id": response["request_id"]}
            else:
                err_msg = json.loads(response["content"])['message']
                analyst_message = {
                    "role": "analyst",
                    "content": [{"type": "text", "text": f"🚨 {err_msg}"}],
                    "request_id": response["request_id"]}
                st.session_state["fire_API_error_notify"] = True

            if "warnings" in response:
                st.session_state.warnings = response["warnings"]
            st.session_state.messages.append(analyst_message)
            st.rerun()


def display_message(
    content: List[Dict[str, Union[str, Dict]]],
    message_index: int,
    request_id: Union[str, None] = None):

    for item in content:
        if item["type"] == "text":
            st.markdown(item["text"])
        elif item["type"] == "suggestions":
            for suggestion_index, suggestion in enumerate(item["suggestions"]):
                if st.button(suggestion, key=f"suggestion_{message_index}_{suggestion_index}"):
                    st.session_state.active_suggestion = suggestion
        elif item["type"] == "sql":
            display_sql_query(item["statement"], message_index, item["confidence"], request_id)


@st.cache_data(show_spinner=False)
def get_query_exec_result(query: str) -> Tuple[Optional[pd.DataFrame], Optional[str]]:
    global session
    try:
        df = session.sql(query).to_pandas()
        return df, None
    except SnowparkSQLException as e:
        return None, str(e)


def display_sql_query(sql: str, message_index: int, confidence: dict, request_id: Union[str, None] = None):

    # Display the SQL query
    with st.expander("SQL Query", expanded=False):
        st.code(sql, language="sql")
        if confidence is not None:
            vqr = confidence["verified_query_used"]
            if vqr is not None:
                with st.popover("Verified Query Used", help="Query used to generate the SQL"):
                    with st.container():
                        st.text(f"Name: {vqr['name']}")
                        st.text(f"Question: {vqr['question']}")
                        st.text(f"Verified by: {vqr['verified_by']}")
                        st.text(f"Verified at: {datetime.fromtimestamp(vqr['verified_at'])}")
                        st.text("SQL query:")
                        st.code(vqr["sql"], language="sql", wrap_lines=True)

    # Display the results of the SQL query
    with st.expander("Results", expanded=True):
        with st.spinner("Running SQL..."):
            df, err_msg = get_query_exec_result(sql)
            if df is None:
                st.error(f"Could not execute generated SQL query. Error: {err_msg}")
            elif df.empty:
                st.write("Query returned no data")
            else:
                # Show query results in two tabs
                data_tab, chart_tab = st.tabs(["Data 📄", "Chart 📉"])
                with data_tab:
                    st.dataframe(df, use_container_width=True)

                # Show a bar chart
                with chart_tab:
                    if len(df.columns) >= 2:
                        all_cols_set = set(df.columns)
                        col1, col2 = st.columns(2)
                        x_col = col1.selectbox("X axis", all_cols_set, key=f"x_col_select_{message_index}")
                        y_col = col2.selectbox("Y axis", all_cols_set.difference({x_col}), key=f"y_col_select_{message_index}")
                        st.bar_chart(df.set_index(x_col)[y_col])
    if request_id:
        display_feedback_section(request_id)


def display_feedback_section(request_id: str):

    with st.popover("📝 Query Feedback"):
        if request_id not in st.session_state.form_submitted:
            with st.form(f"feedback_form_{request_id}", clear_on_submit=True):
                positive = st.radio("Rate the generated SQL", options=["👍", "👎"], horizontal=True)
                positive = positive == "👍"
                submit_disabled = (
                    request_id in st.session_state.form_submitted
                    and st.session_state.form_submitted[request_id])

                feedback_message = st.text_input("Optional feedback message")
                submitted = st.form_submit_button("Submit", disabled=submit_disabled)
                if submitted:
                    resp = _snowflake.send_snow_api_request(
                        "POST", "/api/v2/cortex/analyst/feedback", {}, {}, {
                            "request_id": request_id,
                            "positive": positive,
                            "feedback_message": feedback_message
                        }, None, 50000)
                    parsed_content = json.loads(resp["content"])
                    err_msg = None
                    if resp["status"] != 200:
                        err_msg = f"🚨 {parsed_content['message']}"

                    st.session_state.form_submitted[request_id] = {"error": err_msg}
                    st.session_state.popover_open = False
                    st.rerun()
        
        elif (request_id in st.session_state.form_submitted
            and st.session_state.form_submitted[request_id]["error"] is None):
            st.success("Feedback submitted", icon="✅")
        else:
            st.error(st.session_state.form_submitted[request_id]["error"])


st.title("Cortex Analyst")

if "messages" not in st.session_state:
    st.session_state.messages = []
    st.session_state.active_suggestion = None
    st.session_state.warnings = []
    st.session_state.form_submitted = ({})
    process_user_input("What questions can I ask?")

for idx, message in enumerate(st.session_state.messages):
    role = message["role"]
    content = message["content"]
    with st.chat_message(role):
        if role == "analyst": display_message(content, idx, message["request_id"])
        else: display_message(content, idx)

user_input = st.chat_input("What is your question?")
if user_input:
    process_user_input(user_input)
elif st.session_state.active_suggestion is not None:
    suggestion = st.session_state.active_suggestion
    st.session_state.active_suggestion = None
    process_user_input(suggestion)

if st.session_state.get("fire_API_error_notify"):
    st.toast("An API error has occured!", icon="🚨")
    st.session_state["fire_API_error_notify"] = False

warnings = st.session_state.warnings
for warning in warnings:
    st.warning(warning["message"], icon="⚠️")
