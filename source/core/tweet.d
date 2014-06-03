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
            id,
            userID;
    }

    this (JSONValue tweet)
    {
        lang = tweet["lang"].str;
        text = tweet["text"].str;
        createdAt = tweet["created_at"].str;
        retweetCount = tweet["retweet_count"].integer;
        favoriteCount = tweet["favorite_count"].integer;
        id = tweet["id"].integer;
        userID = tweet["user"].object["id"].integer;
    }
}
