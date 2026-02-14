# AILANG Builtins Reference

> Auto-synced from AILANG v0.8.0. Run `ailang builtins list --by-module` for latest.

```
# $builtin (4)
  _list_head                     [pure]
  _list_length                   [pure]
  _list_nth                      [pure]
  show                           [pure]

# core (2)
  _float_to_int                  [pure]
  _int_to_float                  [pure]

# std/ai (4)
  _ai_call                       [ai]
  _ai_call_json                  [ai]
  _ai_call_json_simple           [ai]
  _ollama_embed                  [io]

# std/array (7)
  _array_from_list               [pure]
  _array_get                     [pure]
  _array_length                  [pure]
  _array_make                    [pure]
  _array_set                     [pure]
  _array_to_list                 [pure]
  _array_unsafe_get              [pure]

# std/bytes (5)
  _bytes_from_base64             [pure]
  _bytes_from_string             [pure]
  _bytes_length                  [pure]
  _bytes_to_base64               [pure]
  _bytes_to_string               [pure]

# std/clock (2)
  _clock_now                     [clock]
  _clock_sleep                   [clock]

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

# std/env (3)
  _env_getArgs                   [env]
  _env_getEnv                    [env]
  _env_hasEnv                    [env]

# std/fs (4)
  _fs_exists                     [fs]
  _fs_readFile                   [fs]
  _fs_readFileBytes              [fs]
  _fs_writeFile                  [fs]

# std/game (3)
  _game_delta_time               [clock]
  _game_frame_count              [clock]
  _game_total_time               [clock]

# std/io (3)
  _io_print                      [io]
  _io_println                    [io]
  _io_readLine                   [io]

# std/json (3)
  _json_decode                   [pure]
  _json_encode                   [pure]
  _json_repair                   [pure]

# std/list (2)
  ::                             [pure]
  concat_List                    [pure]

# std/math (32)
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
  div_Float                      [pure]
  div_Int                        [pure]
  double_Int                     [pure]
  mod_Float                      [pure]
  mod_Int                        [pure]
  mul_Float                      [pure]
  mul_Int                        [pure]
  neg_Float                      [pure]
  neg_Int                        [pure]
  sub_Float                      [pure]
  sub_Int                        [pure]

# std/net (1)
  _net_httpRequest               [net]

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

# std/rand (4)
  _rand_bool                     [rand]
  _rand_float                    [rand]
  _rand_int                      [rand]
  _rand_seed                     [rand]

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

# std/string (18)
  _str_chars                     [pure]
  _str_compare                   [pure]
  _str_endsWith                  [pure]
  _str_eq                        [pure]
  _str_find                      [pure]
  _str_len                       [pure]
  _str_lower                     [pure]
  _str_slice                     [pure]
  _str_split                     [pure]
  _str_startsWith                [pure]
  _str_trim                      [pure]
  _str_upper                     [pure]
  _stringToFloat                 [pure]
  _stringToInt                   [pure]
  _string_floatToStr             [pure]
  _string_intToStr               [pure]
  _string_reverse                [pure]
  concat_String                  [pure]

# std/xml (7)
  _xml_findAll                   [pure]
  _xml_findFirst                 [pure]
  _xml_getAttr                   [pure]
  _xml_getChildren               [pure]
  _xml_getTag                    [pure]
  _xml_getText                   [pure]
  _xml_parse                     [pure]

# std/zip (3)
  _zip_listEntries               [fs]
  _zip_readEntry                 [fs]
  _zip_readEntryBytes            [fs]

# stdlib/trace_test (1)
  _trace_check                   [pure]

```
