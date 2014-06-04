module dwitter.dwitter;

import std.algorithm,
       std.json,
       std.conv,
       twitter4d;
import dwitter.user,
       dwitter.status,
       dwitter.utils.oauth;

class Dwitter
{
    private Twitter4D twitter4d;

    this (string consumerKey, string consumerSecret, string accessToken, string accsessTokenSecret)
    {
        twitter4d = new Twitter4D(consumerKey, consumerSecret, accessToken, accsessTokenSecret);
    }

    // Timelines
    public auto statuses_home_timeline(string[string] options = ["":""])
    {
        return twitter4d.request("GET", "statuses/home_timeline.json", options).parseJSON.array
            .map!(x => (new Status(x)));
    }

    public auto statuses_user_timeline(string[string] options = ["":""])
    {
        return twitter4d.request("GET", "statuses/user_timeline.json", options).parseJSON.array
            .map!(x => (new Status(x)));
    }

    public auto statuses_retweets_of_me(string[string] options = ["":""])
    {
        return twitter4d.request("GET", "statuses/retweets_of_me.json", options).parseJSON.array
            .map!(x => (new Status(x)));
    }

    public auto statuses_mentions_timeline(string[string] options = ["":""])
    {
        return twitter4d.request("GET", "statuses/mentions_timeline.json", options).parseJSON.array
            .map!(x => (new Status(x)));
    }

    // Users
    public auto users_show(ulong id)
    {
        auto params = ["id":id.to!string];
        return new User(twitter4d.request("GET", "users/show.json", params).parseJSON);
    }

    // Tweets
    public auto statuses_show(ulong id, string[string] options = ["":""])
    {
        auto params = options.dup;
        params["id"] = id.to!string;
        return new Status(twitter4d.request("GET", "statuses/show.json", params).parseJSON);
    }

    public auto statuses_retweets(ulong id, string[string] options = ["":""])
    {
        auto params = options.dup;
        params["id"] = id.to!string;
        return new Status(twitter4d.request("GET", "statuses/retweets.json", params).parseJSON);
    }

    public auto statuses_update(string status, string[string] options = ["":""])
    {

        string[string] params;
        if(options != ["":""])
            params = options.dup;
        params["status"] = status;

        return new Status(twitter4d.request("POST", "statuses/update.json", params).parseJSON);
    }

    public auto statuses_destroy(ulong id, string[string] options = ["":""])
    {
        return new Status(twitter4d.request("POST", "statuses/destroy/" ~ id.to!string ~ ".json", options).parseJSON);
    }

    public auto statuses_retweet(ulong id, string[string] options = ["":""])
    {
        return new Status(twitter4d.request("POST", "statuses//" ~ id.to!string ~ ".json", options).parseJSON);
    }
}


class DwitterConstructor
{
    private
    {
        OAuth oauth;
        string consumerKey, consumerSecret;
    }

    this (string consumerKey, string consumerSecret)
    {
        this.consumerKey = consumerKey;
        this.consumerSecret = consumerSecret;
        oauth = new OAuth(consumerKey, consumerSecret);
    }

    public auto getVerifyingURL ()
    {
        return "https://api.twitter.com/oauth/authorize?oauth_token="
            ~ oauth.getRequestToken("https://api.twitter.com/oauth/request_token")["oauth_token"];
    }

    public auto authorize (string verifier)
    {
        auto accessTokens = oauth.getAccessToken("https://api.twitter.com/oauth/access_token", verifier);
        return new Dwitter(consumerKey, consumerSecret, accessTokens["oauth_token"], accessTokens["oauth_token_secret"]);
    }
}
