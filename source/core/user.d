module core.user;
import std.json, std.datetime;

class User
{
	public
	{
		immutable string
			screenName,
			name,
			description,
			location,
			url,
			profileImageURL,
			createdAt;

		immutable ulong
			id,
			statusesCount,
			favouritesCount,
			friendsCount,
			followersCount;
	}

	this(JSONValue user)
	{
		screenName = user["screen_name"].str;
		name = user["name"].str;
		description = user["description"].str;
		location = user["location"].str;
		url = user["url"].str;
		profileImageURL = user["profile_image_url"].str;
		createdAt = user["created_at"].str;
		id = user["id"].integer;
		statusesCount = user["statuses_count"].integer;
		favouritesCount = user["favourites_count"].integer;
		friendsCount = user["friends_count"].integer;
		followersCount = user["followers_count"].integer;
	}
}