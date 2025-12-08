---
description: Create a new AILANG program from a template
arguments:
  - name: name
    description: Name for the new program (without .ail)
    required: true
  - name: template
    description: Template type (hello, http, json, ai)
    required: false
---

Create a new AILANG program named `$ARGUMENTS.name.ail`.

Templates available:
- **hello** (default): Simple hello world with IO
- **http**: HTTP GET request example
- **json**: JSON parsing example
- **ai**: AI effect example

## Templates

### hello (default)
```ailang
module $ARGUMENTS.name

export func main() -> () ! {IO} {
  print("Hello from AILANG!")
}
```

### http
```ailang
module $ARGUMENTS.name
import std/net (httpGet)

export func main() -> () ! {IO, Net} {
  let body = httpGet("https://httpbin.org/get");
  print(body)
}
```

### json
```ailang
module $ARGUMENTS.name
import std/json (decode, encode)

type Person = {name: string, age: int}

export func main() -> () ! {IO} {
  let json = "{\"name\":\"Alice\",\"age\":30}";
  let person = decode[Person](json);
  print(show(person))
}
```

### ai
```ailang
module $ARGUMENTS.name
import std/ai (call)

export func main() -> () ! {IO, AI} {
  let response = call("Hello! Say something brief.");
  print("AI: " ++ response)
}
```

After creating the file, run `ailang check $ARGUMENTS.name.ail` to verify it compiles.
