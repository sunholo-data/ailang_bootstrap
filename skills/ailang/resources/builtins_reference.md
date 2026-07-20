# AILANG Builtins Reference

> Auto-synced from AILANG v0.30.0. Run `ailang builtins list --by-module` for latest.

```
# $builtin (19)
  _list_contains                 [pure]
  _list_dedup                    [pure]
  _list_difference               [pure]
  _list_drop                     [pure]
  _list_extract                  [pure]
  _list_filter                   [pure]
  _list_foldl                    [pure]
  _list_head                     [pure]
  _list_intersect                [pure]
  _list_length                   [pure]
  _list_map                      [pure]
  _list_member                   [pure]
  _list_nth                      [pure]
  _list_reverse                  [pure]
  _list_take                     [pure]
  _list_takeFlatMap              [pure]
  _list_takeMap                  [pure]
  _list_union                    [pure]
  show                           [pure]

# core (2)
  _float_to_int                  [pure]
  _int_to_float                  [pure]

# std/ai (14)
  _ai_call                       [ai]
  _ai_call_image                 [ai]
  _ai_call_image_base64          [ai]
  _ai_call_json                  [ai]
  _ai_call_json_result           [ai]
  _ai_call_json_simple           [ai]
  _ai_call_json_simple_result    [ai]
  _ai_call_result                [ai]
  _ai_call_stream                [ai]
  _ai_step                       [ai]
  _ai_step_with_cache            [ai]
  _ai_step_with_stream           [ai]
  _ai_stream_call                [ai]
  _ollama_embed                  [io]

# std/array (9)
  _array_append                  [pure]
  _array_empty                   [pure]
  _array_from_list               [pure]
  _array_get                     [pure]
  _array_length                  [pure]
  _array_make                    [pure]
  _array_set                     [pure]
  _array_to_list                 [pure]
  _array_unsafe_get              [pure]

# std/bytes (13)
  _bytes_byte_at                 [pure]
  _bytes_concat                  [pure]
  _bytes_concat_list             [pure]
  _bytes_filename                [pure]
  _bytes_from_base64             [pure]
  _bytes_from_base64url          [pure]
  _bytes_from_ints               [pure]
  _bytes_from_string             [pure]
  _bytes_length                  [pure]
  _bytes_mime_type               [pure]
  _bytes_slice                   [pure]
  _bytes_to_base64               [pure]
  _bytes_to_string               [pure]

# std/clock (2)
  _clock_now                     [clock]
  _clock_sleep                   [clock]

# std/cognition (6)
  _cog_drain                     [cog]
  _msg_recv                      [msg]
  _msg_recv_result               [msg]
  _msg_send                      [msg]
  _msg_send_result               [msg]
  _msg_subscribe                 [msg]

# std/crypto (5)
  _crypto_constanttimeequal      [pure]
  _crypto_hmacsha256             [pure]
  _crypto_rsa_verify_pkcs1v15    [pure]
  _crypto_sha256bytes            [pure]
  _crypto_sha256hex              [pure]

# std/datetime (10)
  _dt_add                        [pure]
  _dt_diffDays                   [pure]
  _dt_formatISODate              [pure]
  _dt_formatMonthShort           [pure]
  _dt_formatRFC3339              [pure]
  _dt_formatWeekdayFull          [pure]
  _dt_make                       [pure]
  _dt_parseISODate               [pure]
  _dt_parseRFC3339               [pure]
  _dt_parts                      [pure]

# std/debug (2)
  _debug_check                   [debug]
  _debug_log                     [debug]

# std/deflate (4)
  _deflate_deflate               [pure]
  _deflate_deflateZlib           [pure]
  _deflate_inflate               [pure]
  _deflate_inflateZlib           [pure]

# std/dom (5)
  _dom_apply_batch               [dom]
  _dom_apply_batch_result        [dom]
  _dom_apply_patch               [dom]
  _dom_apply_patch_result        [dom]
  _dom_subscribe                 [dom]

# std/env (3)
  _env_getArgs                   [env]
  _env_getEnv                    [env]
  _env_hasEnv                    [env]

# std/fs (18)
  _fs_appendFile                 [fs]
  _fs_appendFileBytes            [fs]
  _fs_appendFileResult           [fs]
  _fs_exists                     [fs]
  _fs_isDir                      [fs]
  _fs_isFile                     [fs]
  _fs_listDir                    [fs]
  _fs_mkdir                      [fs]
  _fs_mkdirAll                   [fs]
  _fs_mkdirAllResult             [fs]
  _fs_readFile                   [fs]
  _fs_readFileBytes              [fs]
  _fs_readFileResult             [fs]
  _fs_removeFile                 [fs]
  _fs_removeFileResult           [fs]
  _fs_writeFile                  [fs]
  _fs_writeFileBytes             [fs]
  _fs_writeFileResult            [fs]

# std/game (3)
  _game_delta_time               [clock]
  _game_frame_count              [clock]
  _game_total_time               [clock]

# std/gzip (3)
  _gzip_compress                 [pure]
  _gzip_decompress               [pure]
  _gzip_decompressFile           [fs]

# std/html (2)
  _html_parse                    [pure]
  _html_parseFragment            [pure]

# std/http (2)
  _get_header                    [pure]
  _has_header                    [pure]

# std/io (8)
  _io_eprintln                   [io]
  _io_exit                       [io]
  _io_flush                      [io]
  _io_print                      [io]
  _io_printErr                   [io]
  _io_println                    [io]
  _io_readLine                   [io]
  _io_writeBytes                 [io]

# std/json (3)
  _json_decode                   [pure]
  _json_encode                   [pure]
  _json_repair                   [pure]

# std/list (2)
  ::                             [pure]
  concat_List                    [pure]

# std/map (10)
  _map_empty                     [pure]
  _map_from_list                 [pure]
  _map_insert                    [pure]
  _map_keys                      [pure]
  _map_lookup                    [pure]
  _map_member                    [pure]
  _map_remove                    [pure]
  _map_size                      [pure]
  _map_to_list                   [pure]
  _map_values                    [pure]

# std/math (38)
  _math_E                        [pure]
  _math_PI                       [pure]
  _math_abs_Float                [pure]
  _math_abs_Int                  [pure]
  _math_acos                     [pure]
  _math_asin                     [pure]
  _math_atan                     [pure]
  _math_atan2                    [pure]
  _math_ceil                     [pure]
  _math_cos                      [pure]
  _math_exp                      [pure]
  _math_floor                    [pure]
  _math_log                      [pure]
  _math_log10                    [pure]
  _math_pow                      [pure]
  _math_round                    [pure]
  _math_sin                      [pure]
  _math_sqrt                     [pure]
  _math_tan                      [pure]
  add_Float                      [pure]
  add_Int                        [pure]
  bitwiseAnd_Int                 [pure]
  bitwiseNot_Int                 [pure]
  bitwiseOr_Int                  [pure]
  bitwiseXor_Int                 [pure]
  div_Float                      [pure]
  div_Int                        [pure]
  double_Int                     [pure]
  mod_Float                      [pure]
  mod_Int                        [pure]
  mul_Float                      [pure]
  mul_Int                        [pure]
  neg_Float                      [pure]
  neg_Int                        [pure]
  shiftLeft_Int                  [pure]
  shiftRight_Int                 [pure]
  sub_Float                      [pure]
  sub_Int                        [pure]

# std/net (6)
  _net_httpRequest               [net]
  _net_httpRequestBytes          [net]
  _net_url_encode                [pure]
  _net_url_encode_form           [pure]
  _net_url_parse                 [pure]
  _net_url_parse_query           [pure]

# std/package (1)
  _pkg_asset_path                [fs]

# std/prelude (25)
  and_Bool                       [pure]
  eq_Bool                        [pure]
  eq_Float                       [pure]
  eq_Int                         [pure]
  eq_String                      [pure]
  floatToInt                     [pure]
  ge_Float                       [pure]
  ge_Int                         [pure]
  ge_String                      [pure]
  gt_Float                       [pure]
  gt_Int                         [pure]
  gt_String                      [pure]
  intToFloat                     [pure]
  le_Float                       [pure]
  le_Int                         [pure]
  le_String                      [pure]
  lt_Float                       [pure]
  lt_Int                         [pure]
  lt_String                      [pure]
  ne_Bool                        [pure]
  ne_Float                       [pure]
  ne_Int                         [pure]
  ne_String                      [pure]
  not_Bool                       [pure]
  or_Bool                        [pure]

# std/process (4)
  _process_close_stdin           [process]
  _process_exec                  [process]
  _process_spawn_process         [process]
  _process_write_stdin           [process]

# std/rand (5)
  _rand_bool                     [rand]
  _rand_float                    [rand]
  _rand_int                      [rand]
  _rand_seed                     [rand]
  _uuid4                         [rand]

# std/regex (6)
  _regex_compile                 [pure]
  _regex_find_all                [pure]
  _regex_find_first              [pure]
  _regex_is_match                [pure]
  _regex_replace_all             [pure]
  _regex_split                   [pure]

# std/secret (1)
  _secret_read                   [secret]

# std/sem (2)
  _embedding_decode              [pure]
  _embedding_encode              [pure]

# std/sharedindex (7)
  _sharedindex_delete            [sharedindex]
  _sharedindex_entry_count       [sharedindex]
  _sharedindex_find_by_embedding [sharedindex]
  _sharedindex_find_simhash      [sharedindex]
  _sharedindex_namespaces        [sharedindex]
  _sharedindex_upsert            [sharedindex]
  _sharedindex_upsert_emb        [sharedindex]

# std/sharedmem (5)
  _sharedmem_cas                 [sharedmem]
  _sharedmem_delete              [sharedmem]
  _sharedmem_get                 [sharedmem]
  _sharedmem_keys                [sharedmem]
  _sharedmem_put                 [sharedmem]

# std/simhash (2)
  _hamming_distance              [pure]
  _simhash                       [pure]

# std/stream (14)
  _stream_async_exec_process     [stream]
  _stream_async_read_stdin_lines [stream]
  _stream_close                  [stream]
  _stream_connect                [stream]
  _stream_ndjson_post            [stream]
  _stream_onEvent                [stream]
  _stream_runEventLoop           [stream]
  _stream_select_events          [stream]
  _stream_send                   [stream]
  _stream_source_of_conn         [stream]
  _stream_sse_connect            [stream]
  _stream_sse_post               [stream]
  _stream_status                 [stream]
  _stream_transmit_binary        [stream]

# std/string (30)
  _str_charAt                    [pure]
  _str_charCode                  [pure]
  _str_chars                     [pure]
  _str_compare                   [pure]
  _str_decodeQP                  [pure]
  _str_endsWith                  [pure]
  _str_eq                        [pure]
  _str_find                      [pure]
  _str_foldChars                 [pure]
  _str_foldSlices                [pure]
  _str_join                      [pure]
  _str_len                       [pure]
  _str_lower                     [pure]
  _str_mapSlicesJoin             [pure]
  _str_replace                   [pure]
  _str_replaceMany               [pure]
  _str_slice                     [pure]
  _str_split                     [pure]
  _str_splitAny                  [pure]
  _str_startsWith                [pure]
  _str_startsWithIC              [pure]
  _str_trim                      [pure]
  _str_upper                     [pure]
  _str_words                     [pure]
  _stringToFloat                 [pure]
  _stringToInt                   [pure]
  _string_floatToStr             [pure]
  _string_intToStr               [pure]
  _string_reverse                [pure]
  concat_String                  [pure]

# std/tar (6)
  _tar_extractAll                [fs]
  _tar_listEntries               [fs]
  _tar_readEntry                 [fs]
  _tar_readEntryBytes            [fs]
  _tar_readFromGzip              [fs]
  _tar_readFromGzipBytes         [fs]

# std/trace (4)
  _trace_emit                    [trace]
  _trace_event                   [trace]
  _trace_span_end                [trace]
  _trace_span_start              [trace]

# std/trace_test (1)
  _trace_check                   [pure]

# std/xml (26)
  _escapeXml                     [pure]
  _xmlComment                    [pure]
  _xmlElement                    [pure]
  _xmlText                       [pure]
  _xml_findAll                   [pure]
  _xml_findAllAttrs              [pure]
  _xml_findAllTexts              [pure]
  _xml_findFirst                 [pure]
  _xml_flatMapChildren           [pure]
  _xml_foldChildren              [pure]
  _xml_foldChildrenStep          [pure]
  _xml_getAttr                   [pure]
  _xml_getAttrMap                [pure]
  _xml_getChildren               [pure]
  _xml_getTag                    [pure]
  _xml_getText                   [pure]
  _xml_mapChildren               [pure]
  _xml_nodeKind                  [pure]
  _xml_parse                     [pure]
  _xml_parseElements             [pure]
  _xml_parseFold                 [pure]
  _xml_parseFoldStep             [pure]
  _xml_parseWithLimit            [pure]
  _xml_sanitize                  [pure]
  _xml_serialize                 [pure]
  _xml_serializeWithDecl         [pure]

# std/yaml (1)
  _yaml_to_json                  [pure]

# std/zip (7)
  _zip_createArchive             [fs]
  _zip_createArchiveWithBytes    [fs]
  _zip_listEntries               [fs]
  _zip_readEntry                 [fs]
  _zip_readEntryBytes            [fs]
  _zip_xml_scanFold              [fs]
  _zip_xml_scanFoldStep          [fs]

```
