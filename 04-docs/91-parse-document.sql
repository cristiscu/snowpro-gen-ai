-- PARSE_DOCUMENT/AI_PARSE_DOCUMENT
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/parse-document
USE DATABASE test;
CREATE OR REPLACE SCHEMA test.schema1;

CREATE OR REPLACE STAGE stage1
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE'); -- always SSE-encrypted!

-- manually upload in @stage1 the PDF doc .data/docs/predict_2022-11-01.pdf

-- ==================================================
-- PARSE_DOCUMENT
SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
    '@stage1', 'predict_2022-11-01.pdf',
    {'mode': 'OCR'});
/*{
  "content": "SkiGear Co.\n
        1661 Mesa Drive Las Vegas, Nevada\n
        123-555-5555\n
        EQUIPMENT INSPECTION\n
        MACHINE SERIAL NUMBER INSPECTION GRADE\n
        Injection Molder SGMM-12345 PASS\n
        INSPECTION SUMMARY Following a thorough inspection of the injection molder, no issues or concerns were found.\n
        The technician meticulously examined the machine's components and operating systems, ensuring they were all in proper working order. Additionally, the safety measures underwent a comprehensive assessment and were determined to be fully compliant with standards, functioning effectively. As a preventive measure, the technician recommended regular maintenance to sustain the machine's excellent condition for future production runs. Overall,\n
        the inspection confirmed that the machine was operating optimally, meeting safety\n
        regulations, and ready for immediate use.\n
        Injection Unit Gool\n
        Mold Clamping Unit\n
        Hydraulic System\n
        Temperature Control System\n
        Ejector System Good\n
        Lubrication System God\n
        Safety Devices\n
        Control Software Guod\n
        Enily ohnson 2022-1-01\n
        Inspected by Date",
  "metadata": { "pageCount": 1 }
}*/

SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
    '@stage1', 'predict_2022-11-01.pdf',
    {'mode': 'LAYOUT'});
/*{
  "content": "# SkiGear Co.\n\n
        1661 Mesa Drive Las Vegas, Nevada 123-555-5555\n\n
        ## EQUIPMENT INSPECTION\n\n
        |  MACHINE | SERIAL NUMBER | INSPECTION GRADE  |\n
        | --- | --- | --- |\n
        |  Injection Molder | SGMM-12345 | PASS  |\n\n
        ## INSPECTION SUMMARY\n\n
        Following a thorough inspection of the injection molder, no issues or concerns were found. The technician meticulously examined the machine's components and operating systems, ensuring they were all in proper working order. Additionally, the safety measures underwent a comprehensive assessment and were determined to be fully compliant with standards, functioning effectively. As a preventive measure, the technician recommended regular maintenance to sustain the machine's excellent condition for future production runs. Overall, the inspection confirmed that the machine was operating optimally, meeting safety regulations, and ready for immediate use.\n\n
        |  Injection Unit | Good | $\\checkmark$  |\n
        | --- | --- | --- |\n
        |  Mold Clamping Unit | Good | $\\checkmark$  |\n
        |  Hydraulic System | Good | $\\checkmark$  |\n
        |  Temperature Control System | Good | $\\checkmark$  |\n
        |  Ejector System | Good | $\\checkmark$  |\n
        |  Lubrication System | Good | $\\checkmark$  |\n
        |  Safety Devices | Good | $\\checkmark$  |\n
        |  Control Software | Good | $\\checkmark$  |\n\n
        ## Emily Johnson\n\nInspected by\n\n
        ## 2022-12-02\n\n
        Date",
  "metadata": { "pageCount": 1 }
}*/

-- ==================================================
-- AI_PARSE_DOCUMENT
SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@stage1','predict_2022-11-01.pdf'),
    {'mode': 'OCR'});
/*{
  "content": "SkiGear Co.\n1661 Mesa Drive Las Vegas, Nevada\n123-555-5555\nEQUIPMENT INSPECTION\nMACHINE SERIAL NUMBER INSPECTION GRADE\nInjection Molder SGMM-12345 PASS\nINSPECTION SUMMARY Following a thorough inspection of the injection molder, no issues or concerns were found.\nThe technician meticulously examined the machine's components and operating systems, ensuring they were all in proper working order. Additionally, the safety measures underwent a comprehensive assessment and were determined to be fully compliant with standards, functioning effectively. As a preventive measure, the technician recommended regular maintenance to sustain the machine's excellent condition for future production runs. Overall,\nthe inspection confirmed that the machine was operating optimally, meeting safety\nregulations, and ready for immediate use.\nInjection Unit Gool\nMold Clamping Unit\nHydraulic System\nTemperature Control System\nEjector System Good\nLubrication System God\nSafety Devices\nControl Software Guod\nEnily ohnson 2022-1-01\nInspected by Date",
  "metadata": { "pageCount": 1 }
}*/

SELECT AI_PARSE_DOCUMENT (
    TO_FILE('@stage1','predict_2022-11-01.pdf'),
    {'mode': 'LAYOUT', 'page_split': true}); -- for large docs
/*{
  "metadata": { "pageCount": 1 },
  "pages": [{
      "content": "# SkiGear Co.\n\n1661 Mesa Drive Las Vegas, Nevada 123-555-5555\n\n## EQUIPMENT INSPECTION\n\n|  MACHINE | SERIAL NUMBER | INSPECTION GRADE  |\n| --- | --- | --- |\n|  Injection Molder | SGMM-12345 | PASS  |\n\n## INSPECTION SUMMARY\n\nFollowing a thorough inspection of the injection molder, no issues or concerns were found. The technician meticulously examined the machine's components and operating systems, ensuring they were all in proper working order. Additionally, the safety measures underwent a comprehensive assessment and were determined to be fully compliant with standards, functioning effectively. As a preventive measure, the technician recommended regular maintenance to sustain the machine's excellent condition for future production runs. Overall, the inspection confirmed that the machine was operating optimally, meeting safety regulations, and ready for immediate use.\n\n|  Injection Unit | Good | $\\checkmark$  |\n| --- | --- | --- |\n|  Mold Clamping Unit | Good | $\\checkmark$  |\n|  Hydraulic System | Good | $\\checkmark$  |\n|  Temperature Control System | Good | $\\checkmark$  |\n|  Ejector System | Good | $\\checkmark$  |\n|  Lubrication System | Good | $\\checkmark$  |\n|  Safety Devices | Good | $\\checkmark$  |\n|  Control Software | Good | $\\checkmark$  |\n\n## Emily Johnson\n\nInspected by\n\n## 2022-12-02\n\nDate",
      "index": 0
    }]
}*/

SELECT AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'predict_2022-11-01.pdf'),
    {'mode': 'LAYOUT', 'page_filter': [{'start': 0, 'end': 1}]}); -- page_split implied!
/*{
  "metadata": { "pageCount": 1 },
  "pages": [{
      "content": "# SkiGear Co.\n\n1661 Mesa Drive Las Vegas, Nevada 123-555-5555\n\n## EQUIPMENT INSPECTION\n\n|  MACHINE | SERIAL NUMBER | INSPECTION GRADE  |\n| --- | --- | --- |\n|  Injection Molder | SGMM-12345 | PASS  |\n\n## INSPECTION SUMMARY\n\nFollowing a thorough inspection of the injection molder, no issues or concerns were found. The technician meticulously examined the machine's components and operating systems, ensuring they were all in proper working order. Additionally, the safety measures underwent a comprehensive assessment and were determined to be fully compliant with standards, functioning effectively. As a preventive measure, the technician recommended regular maintenance to sustain the machine's excellent condition for future production runs. Overall, the inspection confirmed that the machine was operating optimally, meeting safety regulations, and ready for immediate use.\n\n|  Injection Unit | Good | $\\checkmark$  |\n| --- | --- | --- |\n|  Mold Clamping Unit | Good | $\\checkmark$  |\n|  Hydraulic System | Good | $\\checkmark$  |\n|  Temperature Control System | Good | $\\checkmark$  |\n|  Ejector System | Good | $\\checkmark$  |\n|  Lubrication System | Good | $\\checkmark$  |\n|  Safety Devices | Good | $\\checkmark$  |\n|  Control Software | Good | $\\checkmark$  |\n\n## Emily Johnson\n\nInspected by\n\n## 2022-12-02\n\nDate",
      "index": 0
    }]
}*/

-- cleanup
-- DROP SCHEMA test.schema1;