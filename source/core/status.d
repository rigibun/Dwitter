module core.status;

import std.json,
       std.typecons;
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

        immutable Nullable!ulong inReplyToStatusID;
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
        if(status["in_reply_to_status_id"].type != JSON_TYPE.NULL)
            inReplyToStatusID = status["in_reply_to_status_id"].integer;
    }
}
