module utils.oauth;

class OAuth
{
    import std.algorithm,
           std.net.curl;

    alias Tuple!(string, "key", string, "secret") Token;

    private Token consumer;
    public Token token;
    public string callback;

    this(in string ck, in string cs, in string callbackURI = "oob")
    {
        consumer = Token(ck, cs);
        callback = callbackURI;
    }

    public string[string] getRequestToken(
            in string uri,
            in string http_method = "GET",
            in string sign_method = "HMAC-SHA1",
            in string v = "1.0")
    {
        string[string] params = [
            "oauth_consumer_key"     : consumer.key,
            "oauth_signature_method" : sign_method,
            "oauth_timestamp"        : timestamp,
            "oauth_nonce"            : gen_hex(40),
            "oauth_version"          : v,
            "oauth_callback"         : encode_rfc3986(callback)
            ];
        string[string] res = parseHttpQuery( request(http_method, uri, params) );
        token = Token(res["oauth_token"], res["oauth_token_secret"]);
        return res;
    }

    public string[string] getAccessToken(
            in string uri,
            in string verifier,
            in string http_method = "GET",
            in string sign_method = "HMAC-SHA1",
            in string v = "1.0")
    {
        string[string] params = [
            "oauth_consumer_key"     : consumer.key,
            "oauth_token"            : token.key,
            "oauth_signature_method" : sign_method,
            "oauth_timestamp"        : timestamp,
            "oauth_nonce"            : gen_hex(40),
            "oauth_version"          : v,
            "oauth_verifier"         : verifier
            ];
        string[string] res = parseHttpQuery( request(http_method, uri, params) );
        token = Token(res["oauth_token"], res["oauth_token_secret"]);
        return res;
    }

    private static pure @safe string encode_rfc3986(string text)
    {
        import std.string;
        pure @safe string helper(char c)
        {
            import std.array,
                   std.format;
            auto text = appender!string();
            text.formattedWrite("%02X", c);
            return "%" ~ text.data;
        }
        string code;
        immutable UNESCAPED_STRING = "-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~";
        foreach (immutable c; text)
            code ~= indexOf(UNESCAPED_STRING, c) != -1 ? [c] : helper(c);
        return code;
    }

    @property private static string timestamp()
    {
        import std.conv,
               std.datetime;
        return Clock.currTime().toUnixTime().to!string();
    }

    private static string gen_hex(in int nod)
    {
        import std.array,
               std.format,
               std.random;
        string res;
        for (int i = 0; i < nod; i += 16)
        {
            auto text = appender!string();
            immutable ulong rand = uniform!("[]")(0, 18446744073709551615u);
            formattedWrite(text, "%016X", rand);
            res ~= cast(string) text.data;
        }
        return res[0..nod];
    }

    private static pure ubyte[] hmac_sha1(in string key, in string message)
    {
        import std.array,
               std.digest.sha;
        pure @safe ubyte[] helper(ubyte[] k)
        {
            ubyte[] h = 64 < k.length ? sha1Of(k) : k;
            return h ~ new ubyte[64 - h.length];
        }
        const k = helper(cast(ubyte[]) key);
        return sha1Of(
                array(k.map!q{cast(ubyte) (a^0x5c)}) ~ sha1Of(
                    array(k.map!q{cast(ubyte) (a^0x36)}) ~cast(ubyte[]) message ) ).dup;
    }

    private static string[string] parseHttpQuery(in string s)
    {
        import std.string;
        string[string] result;
        foreach (set; s.split("&").map!q{a.split("=")})
            result[set[0]] = set[1];
        return result;
    }


    private string signInRequest(
            in string uri,
            in string method,
            in string[string] params)
    {
        import std.array,
        std.base64,
        std.algorithm;

        string query = params.keys.sort.map!(k => k ~ "=" ~ params[k]).join("&");

        string key = [consumer.secret, token.secret].map!(
                k => encode_rfc3986(k) ).join("&");
        string base = [method, uri, query].map!(
                k => encode_rfc3986(k) ).join("&");

        return encode_rfc3986( Base64.encode( hmac_sha1(key, base) ) );
    }

    private string request(
            in string method,
            in string uri,
            string[string] params,
            in string[string] option = null)
    {
        return delegate string (string delegate(in string, string, HTTP) call)
        {
            import std.string;

            foreach (k,v; option)  params[k] = encode_rfc3986(v);
            params["oauth_signature"] = signInRequest(uri, method, params);

            string authorize = "OAuth " ~
                params.keys.filter!q{a.countUntil("oauth_")==0}.map!(x => x~"="~params[x]).join(",");
            string opt =
                params.keys.filter!q{a.countUntil("oauth_")!=0}.map!(x => x~"="~params[x]).join("&");

            HTTP http = HTTP();
            http.addRequestHeader("Authorization", authorize);

            return call(uri, opt, http);
        }(method == "GET"
                ? (uri, data, conn) { return cast(immutable) get(0 < data.length ? uri ~ "?" ~ data : uri, conn); }
                : (uri, data, conn) { return cast(immutable) post(uri, data, conn); } );
    }
}
