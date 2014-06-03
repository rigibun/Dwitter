module core.tweet;

import std.json;
import core.user;

class Tweet
{
    public
    {
        immutable string
            lang,
            text,
            createdAt;

        immutable ulong
            retweetCount,
            favoriteCount,
            id;

        const User user;
    }

    this (JSONValue tweet)
    {
        lang = tweet["ja"].str;
        text = tweet["text"].str;
        createdAt = tweet["created_at"].str;
        retweetCount = tweet["retweet_count"].integer;
        favoriteCount = tweet["favorite_count"].integer;
        id = tweet["id"].integer;
        user = new User(tweet["user"]);
    }
}
