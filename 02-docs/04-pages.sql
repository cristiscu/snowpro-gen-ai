-- Multi-Page Document Parsing with AI_PARSE_DOCUMENT
-- in OCR/LAYOUT/AGENTIC modes, for multi-page PDF/DOCX/PPTX staged docs
use test.public;

-- =====================================================================
-- single-page parsing

select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'mode': 'LAYOUT'}   -- same for OCR mode (default)
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 5 },
  "content": "This is page 1\nThis is page 2\nThis is page 3\nThis is page 4\nThis is page 5"
}
*/

select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'mode': 'AGENTIC'}
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 5 },
  "content": "This is page 1\nThis is page 2\nThis is page 3\nThis is page 4\nThis is page 5",
  "images": [],
}*/

-- =====================================================================
-- multi-page splitting (page_split)

select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'mode': 'LAYOUT' , 'page_split': true}  -- same for OCR mode
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 5 },
  "pages": [
    { "content": "This is page 1", "index": 0 },
    { "content": "This is page 2", "index": 1 },
    { "content": "This is page 3", "index": 2 },
    { "content": "This is page 4", "index": 3 },
    { "content": "This is page 5", "index": 4 }
  ]  
}
*/

select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'mode': 'AGENTIC' , 'page_split': true}
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 5 },
  "pages": [
    {
      "content": "This is page 1",
      "dimensions": { "height": 2339, "width": 1654 },
      "images": [],
      "index": 0
    },{
      "content": "This is page 2",
      "dimensions": { "height": 2339, "width": 1654 },
      "images": [],
      "index": 1
    },{
      "content": "This is page 3",
      "dimensions": { "height": 2339, "width": 1654 },
      "images": [],
      "index": 2
    },{
      "content": "This is page 4",
      "dimensions": { "height": 2339, "width": 1654 },
      "images": [],
      "index": 3
    },{
      "content": "This is page 5",
      "dimensions": { "height": 2339, "width": 1654 },
      "images": [],
      "index": 4
    }
  ]
}
*/

-- =====================================================================
-- multi-page filtering (page_filter)

-- second+third pages
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': [{'start': 1, 'end': 3}]}   -- by def OCR
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 2 },
  "pages": [
    { "content": "This is page 2", "index": 1 },
    { "content": "This is page 3", "index": 2 }
  ]
}*/

-- first+second+fourth pages
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': [{'end': 4, 'start': 3}, {'start': 0, 'end': 2}]} -- by def OCR
) as json;
/*
{
  "metadata": { "pageCount": 5, "processedPageCount": 3 },
  "pages": [
    { "content": "This is page 1", "index": 0 },
    { "content": "This is page 2", "index": 1 },
    { "content": "This is page 4", "index": 3 }
  ]
}*/

-- same result, but with negative offsets
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': [{'end': 4, 'start': -2}, {'end': -3}]}
) as json;

-- =====================================================================
-- multi-page filtering (FL_FILTER_PAGES)

-- same result
select AI_PARSE_DOCUMENT(
    FL_FILTER_PAGES(
        TO_FILE('@stage1', 'spool/multi-page.pdf'),
        [{'end': 4, 'start': 3}, {'start': 0, 'end': 2}]),
    {'page_split': TRUE}
) as json;

-- no nested FL_FILTER_PAGES!
select AI_PARSE_DOCUMENT(
    FL_FILTER_PAGES(
        FL_FILTER_PAGES(
            TO_FILE('@stage1', 'spool/multi-page.pdf'),
            [{'end': 4, 'start': 3}]),
        [{'start': 0, 'end': 2}]),
    {'page_split': TRUE}
) as json;

-- with AI_EXTRACT --> list of page numbers
select AI_EXTRACT(
  file => TO_FILE('@stage1', 'spool/multi-page.pdf'),
  responseFormat => {
    'schema': {
      'type': 'object',
      'properties': {
        'pages': {
          'description': 'What are the page numbers?',
          'type': 'array'
        } } } }
) as json;
/*
{
  "error": null,
  "response": { "pages": [ "1", "2", "3", "4", "5" ] }
}
*/

-- with AI_EXTRACT --> for third+fourth pages
select AI_EXTRACT(
    file => FL_FILTER_PAGES(
        TO_FILE('@stage1', 'spool/multi-page.pdf'),
        [{'start': 2, 'end': 4}]),
      responseFormat => {
    'schema': {
      'type': 'object',
      'properties': {
        'pages': {
          'description': 'What are the page numbers?',
          'type': 'array'
        } } } }
) as json;
/*
{
  "error": null,
  "response": { "pages": [ "3", "4" ] }
}
*/

-- =====================================================================
-- special cases

-- last page (page_split redundant)
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': [{'start': 4}], 'page_split': true}
) as json;

-- no page_split (returns nothing)
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': [{'start': 4}], 'page_split': false}
) as json;

-- no pages filtered (returns nothing)
select AI_PARSE_DOCUMENT(
    TO_FILE('@stage1', 'spool/multi-page.pdf'),
    {'page_filter': []}
) as json;
