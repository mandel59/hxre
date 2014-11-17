# HxRE

Pure Haxe implementation of regular expression engine.

This library is based on [libregex](http://doc.rust-lang.org/regex/index.html).

Haxe's macro facility is used to provide compile-time specialization of the regex virtual machine.

# Usage

```hx
@:build(hxre.Specializer.build("(\\d{4})-(\\d{2})-(\\d{2})"))
class SpecialRegex extends hxre.NfaVM {}

class Main {
    public static function main() {
        // dynamic compiled regex
        var re = new hxre.Regex("(\\d{2}):(\\d{2})");
        trace(re.exec("2014-11-20T12:00Z"));

        // static compiled regex
        trace(SpecialRegex.regex.exec("Date: 2014-11-30"));

        // static regex is also able to create new instances
        var sre : hxre.Regex = new SpecialRegex();
        trace(sre.exec("2014-12-31T12:00Z"));
    }
}
```
