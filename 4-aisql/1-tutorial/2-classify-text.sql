-- https://docs.snowflake.com/en/sql-reference/functions/classify_text-snowflake-cortex

SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT('One day I will see the world', ['travel', 'cooking']);

CREATE OR REPLACE TEMPORARY TABLE text_classification_table AS
SELECT 'France' AS input, ['North America', 'Europe', 'Asia'] AS classes
UNION ALL
SELECT 'Singapore', ['North America', 'Europe', 'Asia']
UNION ALL
SELECT 'one day I will see the world', ['travel', 'cooking', 'dancing']
UNION ALL
SELECT 'my lobster bisque is second to none', ['travel', 'cooking', 'dancing'];

SELECT input,
       classes,
       SNOWFLAKE.CORTEX.CLASSIFY_TEXT(input, classes)['label'] as classification
FROM text_classification_table;

SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
  'When I am not at work, I love creating recipes using every day ingredients',
  ['travel', 'cooking', 'fitness'],
  {
    'task_description': 'Return a classification of the Hobby identified in the text'
  }
);

SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
  'I love running every morning before the world wakes up',
  [{
    'label': 'travel',
    'description': 'Hobbies related to going from one place to another',
    'examples': ['I like flying to Europe', 'Every summer we go to Italy' , 'I love traveling to learn new cultures']
  },{
    'label': 'cooking',
    'description': 'Hobbies related to preparing food',
    'examples': ['I like learning about new ingredients', 'You must bring your soul to the recipe' , 'Baking is my therapy']
    },{
    'label': 'fitness',
    'description': 'Hobbies related to being active and healthy',
    'examples': ['I cannot live without my Strava app', 'Running is life' , 'I go to the Gym every day']
    }],
  {'task_description': 'Return a classification of the Hobby identified in the text'})

  SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
  'I love running every morning before the world wakes up',
  [{
    'label': 'travel',
    'description': 'Hobbies related to going from one place to another',
    'examples': ['I like flying to Europe']
  },{
    'label': 'cooking',
    'examples': ['I like learning about new ingredients', 'You must bring your soul to the recipe' , 'Baking is my therapy']
    },{
    'label': 'fitness',
    'description': 'Hobbies related to being active and healthy'
    }],
  {'task_description': 'Return a classification of the Hobby identified in the text'})

  