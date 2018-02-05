# sizes

A small library to format file sizes.

## Example

```d
import bytesize;
import std.format;

// toString defaults to SI units
assert(1.bytes.toString == "1 B");
assert(1.KiB.toString == "1.00 KiB");
assert(1.MiB.toString == "1.00 MiB");
assert(1.GiB.toString == "1.00 GiB");
assert(1.TiB.toString == "1.00 TiB");
assert(1.PiB.toString == "1.00 PiB");
assert(1.EiB.toString == "1.00 EiB");

// use %S format specifier to make them use decimal base
// %S will change it to %f internally
// all format specifiers are only used for manipulating the number
assert(1.bytes.format!"%S" == "1 B");
assert(1.KB.format!"%S" == "1.00 KB");
assert(1.MB.format!"%S" == "1.00 MB");
assert(1.GB.format!"%S" == "1.00 GB");
assert(1.TB.format!"%S" == "1.00 TB");
assert(1.PB.format!"%S" == "1.00 PB");
assert(1.EB.format!"%S" == "1.00 EB");

assert("%g".format(1024.bytes) == "1 KiB");
assert("%.2f".format(2_590_000.bytes) == "2.47 MiB");
```

## Attribution

This library is basically a rewrite of [sizefmt](https://github.com/biozic/sizefmt) which focuses more on adding a new data type you can calculate with and simplicity than being a very flexible string serializer. Use sizefmt if you look for formatting sizes instead of calculating with them.
