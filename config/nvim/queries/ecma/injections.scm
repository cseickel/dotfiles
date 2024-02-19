;extends

; detect_sql_strings
(    
  [
    (string_fragment)
  ] @injection.content
  (#match? @injection.content "(SELECT|INSERT|UPDATE|DELETE).+(FROM|INTO|VALUES|SET)")
  (#set! injection.language "sql")
)
(    
  [
    (string_fragment)
  ] @injection.content
  (#match? @injection.content "(select|insert|update|delete).+(from|into|values|set)")
  (#set! injection.language "sql")
)
(    
  [
    (string_fragment)
  ] @injection.content
  (#match? @injection.content "(ALTER|CREATE|CREATE OR REPLACE|DROP) (TABLE|VIEW|INDEX|PROCEDURE|FUNCTION|SEQUENCE|TRIGGER|SCHEMA|DATABASE|USER|ROLE)")
  (#set! injection.language "sql")
)
(    
  [
    (string_fragment)
  ] @injection.content
  (#match? @injection.content "(alter|create|create or replace|drop) (table|view|index|procedure|function|sequence|trigger|schema|database|user|role)")
  (#set! injection.language "sql")
)
; @dg = document generator
(    
  [
    (comment)
  ] @injection.content
  (#contains? @injection.content "\@dg-")
  (#set! injection.language "markdown")
)

