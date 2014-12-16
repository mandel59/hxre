# HxRE

Pure Haxe implementation of regular expression engine.

This library is based on [libregex](http://doc.rust-lang.org/regex/index.html).

Haxe's macro facility is used to provide compile-time specialization of the regex virtual machine.

**CAUTION**: This is an experimental implementation. DO NOT USE THIS FOR PRODUCTS.

## Usage

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

## Implemented Features

- [x] basic composites and repetitions `ab*|c+|d?|e{2,4}`
- [x] ungreedy repetitions `<.+?>`
- [x] numbered capture group `(abc)`
- [x] non-capturing group `(?:abc)`

## TODO

- [ ] extended hexadecimal escape sequence `\x{10FFFF}`
- [ ] character class `[abcABC0-9]`
- [ ] ASCII character class `[:digit:]`
- [ ] Perl character class `\w`
- [ ] Unicode character class `\p{Han}`
- [ ] case insensitive mode
- [ ] multiline mode
- [ ] global mode
- [ ] named capture group
- [ ] API refinement
