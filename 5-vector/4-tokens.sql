-- https://docs.snowflake.com/en/sql-reference/functions/count_tokens-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.COUNT_TOKENS( 'llama3.1-70b', 'what is a large language model?' );

-- https://docs.snowflake.com/en/sql-reference/functions/ai_count_tokens

SELECT AI_COUNT_TOKENS('ai_complete', 'llama3.3-70b', 'Summarize the insights from this
call transcript in 20 words: "I finally splurged on these after months of hesitation about
the price, and I\'m mostly impressed. The Nulu fabric really is as buttery-soft as everyone says,
and they\'re incredibly comfortable for yoga and lounging. The high-rise waistband stays put
and doesn\'t dig in, which is rare for me. However, I\'m already seeing some pilling after
just a few wears, and they definitely require gentle care. They\'re also quite delicate -
I snagged them slightly on my gym bag zipper. Great for low-impact activities, but I wouldn\'t
recommend for high-intensity workouts. Worth it for the comfort factor"');

SELECT AI_COUNT_TOKENS('ai_embed', 'nv-embed-qa-4', '"I finally splurged on these after months
of hesitation about the price, and I\'m mostly impressed. The Nulu fabric really is as buttery-soft
as everyone says, and they\'re incredibly comfortable for yoga and lounging. The high-rise waistband
stays put and doesn\'t dig in, which is rare for me. However, I\'m already seeing some pilling after
just a few wears, and they definitely require gentle care. They\'re also quite delicate - I snagged
them slightly on my gym bag zipper. Great for low-impact activities, but I wouldn\'t recommend for
high-intensity workouts. Worth it for the comfort factor"');

SELECT AI_COUNT_TOKENS('ai_classify',
  'One day I will see the world and learn to cook my favorite dishes',
  [
      {'label': 'travel'},
      {'label': 'cooking'},
      {'label': 'reading'},
      {'label': 'driving'}
  ]
);

SELECT AI_COUNT_TOKENS('ai_classify',
  'One day I will see the world and learn to cook my favorite dishes',
  [
    {'label': 'travel', 'description': 'content related to traveling'},
    {'label': 'cooking','description': 'content related to food preparation'},
    {'label': 'reading','description': 'content related to reading'},
    {'label': 'driving','description': 'content related to driving a car'}
  ],
  {
    'task_description': 'Determine topics related to the given text'
  };

SELECT AI_COUNT_TOKENS('ai_classify',
  'One day I will see the world and learn to cook my favorite dishes',
  [
    {'label': 'travel', 'description': 'content related to traveling'},
    {'label': 'cooking','description': 'content related to food preparation'},
    {'label': 'reading','description': 'content related to reading'},
    {'label': 'driving','description': 'content related to driving a car'}
  ],
  {
    'task_description': 'Determine topics related to the given text',
    'examples': [
      {
        'input': 'i love traveling with a good book',
        'labels': ['travel', 'reading'],
        'explanation': 'the text mentions traveling and a good book which relates to reading'
      }
    ]
  }
);

SELECT AI_COUNT_TOKENS('ai_sentiment',
  'This place makes the best truffle pizza in the world! Too bad I cannot afford it');

SELECT AI_COUNT_TOKENS('ai_sentiment',
  'This place makes the best truffle pizza in the world! Too bad I cannot afford it',
  [
    {'label': 'positive'},
    {'label': 'negative'},
    {'label': 'neutral'}
  ]
);