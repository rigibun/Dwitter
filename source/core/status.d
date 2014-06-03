module core.status;

import std.json;
import core.user;

class Status
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

    this (JSONValue status)
    {
        lang = status["lang"].str;
        text = status["text"].str;
        createdAt = status["created_at"].str;
        retweetCount = status["retweet_count"].integer;
        favoriteCount = status["favorite_count"].integer;
        id = status["id"].integer;
        userID = status["user"].object["id"].integer;
    }
}
