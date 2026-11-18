-- AI_SENTIMENT
use test.public;

-- overall
SELECT AI_SENTIMENT('The restaurant was excellent.') AS sentiment;
/*
{ "categories": [{ "name": "overall", "sentiment": "positive" }]}
*/

-- overall + in each category
SELECT AI_SENTIMENT(
    'Mediocre food and mediocre service.',
    ['cost', 'quality', 'service', 'wait time']
) AS sentiment;
/*
{
  "categories": [
    { "name": "overall", "sentiment": "negative" },
    { "name": "cost", "sentiment": "neutral" },
    { "name": "quality", "sentiment": "negative" },
    { "name": "service", "sentiment": "negative" },
    { "name": "wait time", "sentiment": "neutral" }
  ]
}
*/

-- on tabular data
WITH cte AS (
    SELECT 'Holly Molly' AS restaurant, 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Sandokan', 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'La Plaza', 'Mediocre food and mediocre service.')
SELECT restaurant, AI_SENTIMENT(review) AS sentiment
FROM cte;

SELECT AI_SENTIMENT('These high-end luxury shoes are designed to make a statement. Crafted from premium leather with precise stitching, polished details, and a sleek silhouette, they immediately look expensive and exclusive. The craftsmanship is impressive, and their sophisticated appearance makes them an excellent match for formal outfits, tailored suits, and upscale events.

However, comfort is where these shoes fall dramatically short. The leather is extremely stiff, particularly when new, and the structured design gives the foot very little freedom to move naturally. The narrow toe box can create uncomfortable pressure around the toes, while the rigid heel may cause rubbing after only a short period of walking.

Despite their premium price, cushioning is surprisingly limited. The sole feels hard underfoot, meaning extended periods of standing or walking can quickly become tiring. After several hours, wearers may experience soreness around the heel and ball of the foot. Breaking them in can improve the experience slightly, but they are unlikely to ever feel like genuinely comfortable everyday footwear.

Ultimately, these shoes prioritize appearance, craftsmanship, and exclusivity over practicality. They look exceptional and can elevate an expensive outfit, but wearing them for an entire day could be a challenge. They are best suited to formal dinners, ceremonies, luxury events, or other occasions where minimal walking is required.

For buyers who value comfort above everything else, these shoes are difficult to recommend. For those willing to sacrifice comfort for an elegant design and prestigious appearance, however, they certainly deliver the desired luxury aesthetic.');

-- ==============================================================
-- legacy function (may not work in some accounts)

-- returns -1..1
SELECT SNOWFLAKE.CORTEX.SENTIMENT('The restaurant was excellent.') AS sentiment;

-- returns -1..1
SELECT SNOWFLAKE.CORTEX.SENTIMENT($$ I am a new customer for less than a year and I have never had to visit a branch this much in my lifetime. I've had my banking card locked THREE times for fraud. No fraudulent payments were made, nor anything else beside trying to put my card in my wallet on my phone. Since I live over an hour away from the nearest branch, they gave me a virtual appointment to unlock my card, and never gave my the joining code so I couldn't access it. I can't make any payments on my credit card because I can't access my online banking, so now they're adding interest to it. And as this is the third time my account was frozen for fraud, it has also been going on for TWO MONTHS. I'm canceling both my debit and credit cards ASAP when I can access a branch which I'll either have to miss work for as a contract worker, or go to my nearest city, carless, which is again over an hour away, 2 hours by bus, on the weekend.$$) AS sentiment;

-- in each category --> -1..1
SELECT SNOWFLAKE.CORTEX.ENTITY_SENTIMENT('Mediocre food and mediocre service.') AS sentiment;
/*
{ "categories": [{ "name": "overall", "sentiment": "negative" }]}
*/

SELECT SNOWFLAKE.CORTEX.ENTITY_SENTIMENT(
    'Mediocre food and mediocre service.',
    ['cost', 'quality', 'service', 'wait time']
) AS sentiment;
/*
{
  "categories": [
    { "name": "overall", "sentiment": "negative" },
    { "name": "cost", "sentiment": "neutral" },
    { "name": "quality", "sentiment": "negative" },
    { "name": "service", "sentiment": "negative" },
    { "name": "wait time", "sentiment": "neutral" }
  ]
}
*/
