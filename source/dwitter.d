module dwitter.dwitter;

import std.algorithm,
       std.json,
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
    public auto statuses_home_timeline(string[string] params = ["":""])
    {
        return twitter4d.request("GET", "statuses/home_timeline.json", params).parseJSON.array
            .map!(x => (new Status(x)));
    }

    public auto statuses_mentions_timeline(string[string] params = ["":""])
    {
        return twitter4d.request("GET", "statuses/mentions_timeline.json", params).parseJSON.array
            .map!(x => (new Status(x)));
    }

    // Users
    public auto users_show(string id)
    {
        auto params = ["id":id];
        return new User(twitter4d.request("GET", "users/show.json", params).parseJSON);
    }

    // Statuses
    public auto statuses_show(string id)
    {
        auto params = ["id":id];
        return new Status(twitter4d.request("GET", "statuses/show.json", params).parseJSON);
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
