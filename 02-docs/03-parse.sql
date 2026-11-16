-- Basic Document Parsing with AI_PARSE_DOCUMENT
use test.public;

-- ==================================================================
-- extract text --> as text/markdown

select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/inspection.pdf'),
    {'mode': 'OCR'}
) as json;
/*
{
  "content": "SkiGear Co.\n1661 Mesa Drive\nLas Vegas, Nevada\n123-555-5555\n...",
  "metadata": { "pageCount": 1, "processedPageCount": 1 }
}
*/

-- try also w/ inspection.png --> same result
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/inspection.pdf'),
    {'mode': 'OCR'},
    true) as json,
    json:content::STRING as content;
/*
{
  "content": "SkiGear Co.
        1661 Mesa Drive
        Las Vegas, Nevada
        123-555-5555
        EQUIPMENT INSPECTION
        MACHINE SERIAL NUMBER INSPECTION GRADE
        Injection Molder SGMM-12345 PASS
        INSPECTION SUMMARY...",
  "metadata": { "pageCount": 1, "processedPageCount": 1 },
  "errors": none
}
*/

-- ==================================================================
-- extract layout

-- with table/form --> see content in https://markdownlivepreview.com/
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/inspection.pdf'),
    {'mode': 'LAYOUT'}) as json,
    json:content::STRING as content;
/*
{
  "content": "SkiGear Co.
        1661 Mesa Drive
        Las Vegas, Nevada
        123-555-5555
        # EQUIPMENT INSPECTION
        |  MACHINE | SERIAL NUMBER | INSPECTION GRADE  |
        | --- | --- | --- |
        |  Injection Molder | SGMM-12345 | PASS  |
        ## INSPECTION SUMMARY...",
  "metadata": { "pageCount": 1, "processedPageCount": 1 }
}
*/

-- ==================================================================
-- extract images (in base64/as type)

-- with base 64 images --> see img in https://jaredwinick.github.io/base64-image-viewer/
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/study-guide.pdf'),
    {'mode': 'LAYOUT', 'extract_images': true }) as json,
    json:images[0].image_base64::STRING as img;
/*
{
  "content": "snowflake\n\n# SNOWPRO® SPECIALTY...",
  "images": [{
      "id": "img-0.jpeg",
      "image_base64": "data:image/jpeg;base64,..."
      "top_left_x": 307, "top_left_y": 1801,
      "bottom_right_x": 1400, "bottom_right_y": 2063
    },...],
  "metadata": { "pageCount": 16, "processedPageCount": 16 }
}
*/

-- see content in https://markdownlivepreview.com/
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/study-guide.pdf'),
    {'mode': 'AGENTIC'}) as json,
    json:content::STRING as content;
/*
{
  "content": "snowflake
        # SNOWPRO® SPECIALTY: GEN AI EXAM STUDY GUIDE
        Last Updated: April 30, 2026
        ![img-0.jpeg](img-0.jpeg)
        Page 2
        # TABLE OF CONTENTS:...",
  "images": [{
      "id": "img-0.jpeg",
      "results": {
        "description": "A horizontal banner composed of four rounded, overlapping vertical panels in shades of blue and grey, each containing a white line-art icon. From left to right: the first panel (dark grey) shows a brain with circuit-like nodes extending from it; the second panel (dark blue) shows a network graph of interconnected nodes; the third panel (medium grey-blue) shows a padlock; the fourth panel (light blue) shows a document icon with a small network graph badge in the bottom right corner.",
        "image_type": "other",
        "visible_text": []
      },
      "top_left_x": 307, "top_left_y": 1801,
      "bottom_right_x": 1400, "bottom_right_y": 2063
    }
  ],
  "metadata": { "pageCount": 16, "processedPageCount": 16 }
}
*/

-- legacy function (may not work in new accounts!)
select SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
    @stage1, 'spool/inspection.pdf', {'mode': 'OCR'}) as json;
