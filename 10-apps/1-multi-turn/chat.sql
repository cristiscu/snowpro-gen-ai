-- single-turn conversation
SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet',
    [{'role':'user','content':'This is a wonderful day indeed!'}], { });
-- User: This is a wonderful day indeed! --> claude-3-5-sonnet: I'm glad you're having a wonderful day! Your enthusiasm is contagious. What makes today particularly wonderful for you?

SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet',
    [{'role':'user','content':'How is my day so far?'}], { });
-- User: How is my day so far? --> claude-3-5-sonnet: I don't know how your day has been so far. I can only respond based on information you share with me. Would you like to tell me about your day?

-- =========================================================
-- multi-turn conversation
SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet',
    [{'role':'user','content':'This is a wonderful day indeed!'},
    {'role':'assistant','content':'I''m glad you''re having a wonderful day! Your enthusiasm is contagious. What makes today particularly wonderful for you?'},
    {'role':'user','content':'How is my day so far?'}], {});
/* {
  "choices": [{"messages": "Based on your previous comment \"This is a wonderful day indeed!\", you indicated that you're having a wonderful day. However, you didn't share specific details about why your day is wonderful, so I can't tell you exactly how your day is going beyond knowing that you described it as wonderful."}],
  "created": 1761387203,
  "model": "claude-3-5-sonnet",
  "usage": {"completion_tokens": 62, "prompt_tokens": 52, "total_tokens": 114}
} */

SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet',
    [{'role':'user','content':'This is a wonderful day indeed!'},
    {'role':'assistant','content':'...'},
    {'role':'user','content':'How is my day so far?'}], {});
/* {
  "choices": [{"messages": "Based on your first message, it seems you're having a wonderful day! You appear to be in a positive mood."}],
  "created": 1761387372,
  "model": "claude-3-5-sonnet",
  "usage": {"completion_tokens": 27, "prompt_tokens": 28, "total_tokens": 55}
} */