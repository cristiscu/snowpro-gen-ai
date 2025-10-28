SELECT SNOWFLAKE.CORTEX.FINETUNE('SHOW');
/*
--> [{
    "id":"ft_9544250a-20a9-42b3-babe-74f0a6f88f60",
    "status":"SUCCESS",     <-- PENDING/IN_PROGRESS/SUCCESS/ERROR/CANCELLED
    "base_model":"llama3.1-8b",
    "created_on":1730835118114
  }, {
    "id":"ft_354cf617-2fd1-4ffa-a3f9-190633f42a25",
    "status":"ERROR",
    "base_model":"llama3.1-8b",
    "created_on":1730834536632
}]
*/

SELECT SNOWFLAKE.CORTEX.FINETUNE('CREATE',
  'my_tuned_model', 'mistral-7b',
  'SELECT prompt, completion FROM train',
  'SELECT prompt, completion FROM validation');
-- --> ft_6556e15c-8f12-4d94-8cb0-87e6f2fd2299

SELECT SNOWFLAKE.CORTEX.FINETUNE('DESCRIBE',
  'ft_6556e15c-8f12-4d94-8cb0-87e6f2fd2299');
/*
--> {
  "base_model":"mistral-7b",
  "created_on":1717004388348,
  "finished_on":1717004691577,
  "id":"ft_6556e15c-8f12-4d94-8cb0-87e6f2fd2299",
  "model":"mydb.myschema.my_tuned_model",
  "progress":1.0,		    <-- 0..1
  "status":"SUCCESS", 	    <-- PENDING/IN_PROGRESS/SUCCESS/ERROR/CANCELLED
  "training_data":"SELECT prompt, completion FROM train",
  "trained_tokens":2670734,
  "training_result":{"validation_loss":1.013819,"training_loss":0.6477747},
  "validation_data":"SELECT prompt, completion FROM validation",
  "options":{"max_epochs":3}}
*/

SELECT SNOWFLAKE.CORTEX.FINETUNE('CANCEL',
  'ft_194bbea4-1208-42f3-88c6-cfb202086125');
-- --> Canceled Cortex Fine-tuning job: ft_194bbea4-1208-42f3-88c6-cfb202086125
