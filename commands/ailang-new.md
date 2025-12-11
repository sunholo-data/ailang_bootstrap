---
description: "Create new AILANG file: /ailang-new <name> [hello|http|json|ai]"
arguments:
  - name: name
    description: Program name (without .ail extension)
    required: true
  - name: template
    description: "Template: hello (default), http, json, or ai"
    required: false
---

Create a new AILANG file named `$1.ail` using the specified template.

**Arguments:** `$1` = filename, `$2` = template (default: hello)

## ACTION REQUIRED

You MUST create the file `$1.ail` with the appropriate template content below.

### If template is "hello" or not specified:

Write this to `$1.ail`:
```ailang
module $1

export func main() -> () ! {IO} {
  print("Hello from AILANG!")
}
```

Then run: `ailang check $1.ail && ailang run --caps IO --entry main $1.ail`

### If template is "http":

Write this to `$1.ail`:
```ailang
module $1
import std/net (httpGet)

export func main() -> () ! {IO, Net} {
  let body = httpGet("https://httpbin.org/get");
  print(body)
}
```

Then run: `ailang check $1.ail && ailang run --caps IO,Net --entry main $1.ail`

### If template is "json":

Write this to `$1.ail`:
```ailang
module $1
import std/json (decode)

export func main() -> () ! {IO} {
  let json = "{\"name\":\"Alice\",\"age\":30}";
  let data = decode(json);
  print(show(data))
}
```

Then run: `ailang check $1.ail && ailang run --caps IO --entry main $1.ail`

### If template is "ai":

Write this to `$1.ail`:
```ailang
module $1
import std/ai (call)

export func main() -> () ! {IO, AI} {
  let response = call("Hello! Say something brief.");
  print("AI: " ++ response)
}
```

Then run: `ailang check $1.ail && ailang run --caps IO,AI --entry main $1.ail`

## After Creating

1. Confirm the file was created
2. Run the check command to verify it compiles
3. Run the program to show it works
