import os
from snowflake.snowpark.context import get_active_session
from snowflake.core import Root
from snowflake.cortex import complete

from trulens.core.otel.instrument import instrument
from trulens.otel.semconv.trace import SpanAttributes
from trulens.apps.app import TruApp
from trulens.connectors.snowflake import SnowflakeConnector
from trulens.core.run import Run, RunConfig

os.environ["TRULENS_OTEL_TRACING"] = "1"
session = get_active_session()
session.use_schema("observability_db.observability_schema")

class RAG:
    @instrument(span_type=SpanAttributes.SpanType.RETRIEVAL,
        attributes={
            SpanAttributes.RETRIEVAL.QUERY_TEXT: "query",
            SpanAttributes.RETRIEVAL.RETRIEVED_CONTEXTS: "return"})
    def retrieve_context(self, query: str) -> list:
        srv = Root(session).databases["..."].schemas["..."].cortex_search_services["..."]
        resp = srv.search(query=query, columns=["chunk"], limit=4)
        return [curr["chunk"] for curr in resp.results]

    @instrument(span_type=SpanAttributes.SpanType.GENERATION)
    def generate_completion(self, query: str, context_str: list) -> str:
        prompt = f"""
          You are an expert assistant extracting information from context provided.
          Answer the question in long-form, fully and completely, based on the context. Do not hallucinate.
          If you don´t have the information just say so.
          Context: {context_str}
          Question: {query}
          Answer:
        """
        response = ""
        stream = complete("mistral-large2", prompt, stream = True)
        for update in stream:    
          response += update
          print(update, end = '')
        return response

    @instrument(span_type=SpanAttributes.SpanType.RECORD_ROOT, 
        attributes={
            SpanAttributes.RECORD_ROOT.INPUT: "query",
            SpanAttributes.RECORD_ROOT.OUTPUT: "return"})
    def query(self, query: str) -> str:
        context_str = self.retrieve_context(query)
        return self.generate_completion(query, context_str)

rag = RAG()
conn = SnowflakeConnector(snowpark_session=session)
tru_rag = TruApp(rag, app_name="...", app_version="...", connector=conn)

run_config = RunConfig(
    run_name="experiment_1_run",
    dataset_name="FOMC_DATA",
    description="Questions about the Federal Open Market Committee meetings",
    label="fomc_rag_eval",
    source_type="TABLE",
    dataset_spec={
        "input": "QUERY",
        "ground_truth_output":"GROUND_TRUTH_RESPONSE"})

run: Run = tru_rag.add_run(run_config=run_config)
run.start()
run.compute_metrics(["answer_relevance", "context_relevance", "groundedness"])