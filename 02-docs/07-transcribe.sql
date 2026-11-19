-- Transcript Extraction with AI_TRANSCRIBE
-- for audio/video staged files (test.MP4/WAV)
use test.public;

SELECT AI_TRANSCRIBE(TO_FILE('@stage1', 'spool/media/test.mp4')) as json;
/*
{
  "text": "Welcome to practice tests for the SnowPro Specialty GenAI exam.",
  "audio_duration": 7.968
}*/

SELECT AI_TRANSCRIBE(TO_FILE('@stage1', 'spool/media/test.wav')) as json;
/*
{
  "text": "Welcome to practice tests for the SnowPro Specialty GenAI exam.",
  "audio_duration": 7.968
}
*/

SELECT AI_TRANSCRIBE(
    TO_FILE('@stage1', 'spool/media/test.wav'),
    {'timestamp_granularity': 'word'}
) as json;
/*
{
  "text": "Welcome to practice tests for the SnowPro Specialty GenAI exam.",
  "audio_duration": 7.968,
  "segments": [
    { "text": "Welcome", "start": 2.125, "end": 2.688 },
    { "text": "to", "start": 2.728, "end": 2.929 },
    ...
    { "text": "exam.", "start": 7.285, "end": 7.587 }
  ]
}*/

SELECT AI_TRANSCRIBE(
    TO_FILE('@stage1', 'spool/media/test.wav'),
    {'timestamp_granularity': 'speaker'},
    true
) as json;
/*
{
  "text": "Welcome to practice tests for the SnowPro Specialty GenAI exam.",
  "audio_duration": 7.968,
  "error": null,
  "segments": [{
      "text": "Welcome to practice tests for the SnowPro Specialty GenAI exam.",
      "speaker_label": "SPEAKER_00", "start": 2.125, "end": 7.587
    }]
}
*/
