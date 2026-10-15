; extends
; SQL внутри Go-строк подсвечивается как SQL: `SELECT …`, "INSERT INTO …" — по первому слову запроса
((raw_string_literal
  (raw_string_literal_content) @injection.content)
  (#match? @injection.content "\\v\\c^\\_s*(select|insert|update|delete|with|create|alter|drop)>")
  (#set! injection.language "sql"))

((interpreted_string_literal
  (interpreted_string_literal_content) @injection.content)
  (#match? @injection.content "\\v\\c^\\s*(select|insert|update|delete|with)>")
  (#set! injection.language "sql"))
