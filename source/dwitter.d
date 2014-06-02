import utils.oauth;
import twitter4d;

class Dwitter
{
    private Twitter4D twitter4d;

    this (string consumerKey, string consumerSecret, string accessToken, string accsessTokenSecret)
    {
        twitter4d = new Twitter4D(consumerKey, consumerSecret, accessToken, accsessTokenSecret);
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
