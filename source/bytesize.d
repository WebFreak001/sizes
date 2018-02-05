module bytesize;

import std.meta : AliasSeq;

import std.math : pow;
import std.format : FormatSpec, formatValue;

///
struct ByteSize
{
	/// Converts this byte size to a string, use %f for base 1024 or %F for base 1000
	void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt) const
	{
		int base = 1024;
		if (fmt.precision == FormatSpec!char.UNSPECIFIED)
			fmt.precision = 2;

		if (fmt.spec == 's')
			fmt.spec = 'f';
		else if (fmt.spec == 'S')
		{
			base = 1000;
			fmt.spec = 'f';
		}

		static immutable string PrefixList = "_KMGTPE";

		long tmp = bytes;
		int order;
		while (tmp > (base - 1))
		{
			tmp /= base;
			order++;
		}
		// as a long can only hold up to 8EiB we don't need to index check here
		double val = bytes / pow(cast(double) base, order);
		if (order > 0)
			formatValue(sink, val, fmt);
		else
		{
			auto ifmt = fmt;
			ifmt.spec = 'd';
			ifmt.precision = 1;
			formatValue(sink, bytes, ifmt);
		}
		sink(" ");
		if (order > 0)
		{
			sink([PrefixList[order]]);
			if (base == 1024)
				sink("i");
		}
		sink("B");
	}

	string toString() const
	{
		const(char)[] s;
		toString((d) { s ~= d; }, FormatSpec!char("%s"));
		return cast(string) s;
	}

@safe pure:
	/++
		A $(D ByteSize) of $(D 0). It's shorter than doing something like
		$(D size!"bytes"(0)) and more explicit than $(D ByteSize.init).
	+/
	static @property nothrow @nogc ByteSize zero()
	{
		return ByteSize(0);
	}

	/++
			Largest $(D ByteSize) possible.
		+/
	static @property nothrow @nogc ByteSize max()
	{
		return ByteSize(long.max);
	}

	/++
			Most negative $(D ByteSize) possible.
		+/
	static @property nothrow @nogc ByteSize min()
	{
		return ByteSize(long.min);
	}

	///
	long bytes;

	int opCmp(ByteSize rhs) const nothrow @nogc
	{
		if (bytes < rhs.bytes)
			return -1;
		if (bytes > rhs.bytes)
			return 1;
		return 0;
	}

	bool opEquals(ByteSize b) const nothrow @nogc
	{
		return bytes == b.bytes;
	}

	hash_t toHash() const nothrow @nogc
	{
		return cast(hash_t) bytes;
	}

	///
	bool isNegative() const nothrow @nogc
	{
		return bytes < 0;
	}

	///
	T total(string unit, T = long)() const nothrow @nogc
	{
		return cast(T)(bytes / cast(T) bytesInUnit!unit);
	}

	///
	auto opBinary(string op)(ByteSize rhs) const
	{
		return ByteSize(mixin("bytes " ~ op ~ " rhs.bytes"));
	}

	///
	auto opUnary(string op)() const
	{
		return ByteSize(mixin(op ~ "bytes"));
	}
}

static assert(__traits(isPOD, ByteSize));

///
unittest
{
	import std.format;

	assert(1.bytes.toString == "1 B");
	assert(1.KiB.toString == "1.00 KiB");
	assert(1.MiB.toString == "1.00 MiB");
	assert(1.GiB.toString == "1.00 GiB");
	assert(1.TiB.toString == "1.00 TiB");
	assert(1.PiB.toString == "1.00 PiB");
	assert(1.EiB.toString == "1.00 EiB");

	assert(1.bytes.format!"%S" == "1 B");
	assert(1.KB.format!"%S" == "1.00 KB");
	assert(1.MB.format!"%S" == "1.00 MB");
	assert(1.GB.format!"%S" == "1.00 GB");
	assert(1.TB.format!"%S" == "1.00 TB");
	assert(1.PB.format!"%S" == "1.00 PB");
	assert(1.EB.format!"%S" == "1.00 EB");

	assert("%g".format(1024.bytes) == "1 KiB");
	assert("%.2f".format(2_590_000.bytes) == "2.47 MiB");
}

/// Returns the number of bytes per one unit
enum bytesInUnit(string unit) = {
	switch (unit)
	{
	case "bytes":
		return 1;
	case "KB":
		return 1000L;
	case "KiB":
		return 1024L;
	case "MB":
		return 1000L * 1000L;
	case "MiB":
		return 1024L * 1024L;
	case "GB":
		return 1000L * 1000L * 1000L;
	case "GiB":
		return 1024L * 1024L * 1024L;
	case "TB":
		return 1000L * 1000L * 1000L * 1000L;
	case "TiB":
		return 1024L * 1024L * 1024L * 1024L;
	case "PB":
		return 1000L * 1000L * 1000L * 1000L * 1000L;
	case "PiB":
		return 1024L * 1024L * 1024L * 1024L * 1024L;
	case "EB":
		return 1000L * 1000L * 1000L * 1000L * 1000L * 1000L;
	case "EiB":
		return 1024L * 1024L * 1024L * 1024L * 1024L * 1024L;
	default:
		assert(false,
				"Can only use bytes, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB, EB, EiB as units");
	}
}();

//dfmt off
// only doing this so auto completion helps you...

/// Convenience method to convert to a ByteSize using `bytesInUnit`
ByteSize bytes(long l) { return ByteSize(l); }
/// ditto
ByteSize KB(long l) { return ByteSize(l * bytesInUnit!"KB"); }
/// ditto
ByteSize KiB(long l) { return ByteSize(l * bytesInUnit!"KiB"); }
/// ditto
ByteSize MB(long l) { return ByteSize(l * bytesInUnit!"MB"); }
/// ditto
ByteSize MiB(long l) { return ByteSize(l * bytesInUnit!"MiB"); }
/// ditto
ByteSize GB(long l) { return ByteSize(l * bytesInUnit!"GB"); }
/// ditto
ByteSize GiB(long l) { return ByteSize(l * bytesInUnit!"GiB"); }
/// ditto
ByteSize TB(long l) { return ByteSize(l * bytesInUnit!"TB"); }
/// ditto
ByteSize TiB(long l) { return ByteSize(l * bytesInUnit!"TiB"); }
/// ditto
ByteSize PB(long l) { return ByteSize(l * bytesInUnit!"PB"); }
/// ditto
ByteSize PiB(long l) { return ByteSize(l * bytesInUnit!"PiB"); }
/// ditto
ByteSize EB(long l) { return ByteSize(l * bytesInUnit!"EB"); }
/// ditto
ByteSize EiB(long l) { return ByteSize(l * bytesInUnit!"EiB"); }

/// ditto
ByteSize size(string unit)(long l) { return ByteSize(l * bytesInUnit!unit); }
//dfmt on
