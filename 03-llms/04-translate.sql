-- Translations
use test.public;

-- simple use cases
SELECT AI_TRANSLATE('Good Morning!', 'en', 'fr');
SELECT AI_TRANSLATE('Good Morning!', '', 'fr');

-- nesting (back and forth)
SELECT AI_TRANSLATE(AI_TRANSLATE('Good Morning!', '', 'fr'), '', 'en');

-- on tabular data
WITH cte AS (
    SELECT 'Holly Molly' AS restaurant, 'The restaurant was excellent.' AS review
    UNION ALL SELECT 'Sandokan', 'Excellent! I loved the pizza!'
    UNION ALL SELECT 'La Plaza', 'Mediocre food and mediocre service.')
SELECT restaurant, AI_TRANSLATE(review, '', 'ro') AS sentiment
FROM cte;

-- from session variable
SET txt = $$The SnowPro® Specialty: Gen AI Certification Exam will validate specialized knowledge, skills, and best practices used to leverage Gen AI methodologies in Snowflake including key concepts, features, and programming constructs.

This certification will test the ability to:

Define and implement Snowflake Gen AI principles, capabilities, and best practices

Use Snowflake Cortex AI features and functions, including LLMs, to meet customer use cases

Build and fine-tune open-source models with Snowpark Container Services and Snowflake Model Registry

Use Snowflake document processing functions to build, manage, and optimize document parsing pipelines
$$;

SELECT AI_TRANSLATE($txt, 'en', 'fr');
SELECT AI_TRANSLATE($txt, '', 'ro');

-- ====================================================================
-- legacy (may not work in some accounts)

SELECT SNOWFLAKE.CORTEX.TRANSLATE('Good Morning!', 'en', 'fr');
