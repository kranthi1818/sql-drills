
CREATE TABLE IF NOT EXISTS organizations(
  organization_id INTEGER PRIMARY KEY auto_increment,
  organization_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Channels(
   channel_id INTEGER PRIMARY KEY auto_increment,
   channel_name VARCHAR(50) NOT NULL,
   organization_id INTEGER NOT NULL,
   foreign key (organization_id ) references organizations( organization_id) 
);


CREATE TABLE IF NOT EXISTS Users(
   user_id INTEGER PRIMARY KEY auto_increment,
   user_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS channel_subscription(
    sub_user_id INTEGER NOT NULL,
    sub_channel_id INTEGER NOT NULL,
    PRIMARY KEY (sub_user_id,sub_channel_id),
    FOREIGN KEY ( sub_user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY ( sub_channel_id) REFERENCES Channels(channel_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS messages(
   message_id INT PRIMARY KEY auto_increment,
   message_user_id INTEGER NOT NULL,
   message_channel_id INTEGER NOT NULL,
   post_time DATETIME NOT NULL DEFAULT current_timestamp,
   content TEXT NOT NULL,
   FOREIGN KEY (message_user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
   FOREIGN KEY (message_channel_id) REFERENCES Channels(channel_id) ON DELETE CASCADE
);

INSERT INTO organizations(organization_name) VALUES ("Lambda School");
SELECT * FROM organizations;

INSERT INTO Users(user_name) VALUES ("Alice"), ("Bob"), ("Chris");
SELECT * FROM Users;

INSERT INTO Channels(channel_name,organization_id) VALUES ("#general",1), ("#random",1);
select * from Channels;


INSERT INTO channel_subscription(sub_user_id,sub_channel_id) 
VALUES(1,1),
(1,2),
(2,1),
(3,2);

select * from channel_subscription;
-- Insert messages with dynamically fetched user_id and channel_id
INSERT INTO messages (message_user_id, message_channel_id, content) VALUES
((SELECT user_id FROM Users WHERE user_name = 'Alice'), (SELECT channel_id FROM Channels WHERE channel_name = '#general'), 'Hello #general'),
((SELECT user_id FROM Users WHERE user_name = 'Bob'), (SELECT channel_id FROM Channels WHERE channel_name = '#general'), 'Hey #general'),
((SELECT user_id FROM Users WHERE user_name = 'Chris'), (SELECT channel_id FROM Channels WHERE channel_name = '#random'), 'Chris #random'),
((SELECT user_id FROM Users WHERE user_name = 'Alice'), (SELECT channel_id FROM Channels WHERE channel_name = '#random'), 'Alice #random'),
((SELECT user_id FROM Users WHERE user_name = 'Bob'), (SELECT channel_id FROM Channels WHERE channel_name = '#general'), 'Bob-hello'),
((SELECT user_id FROM Users WHERE user_name = 'Chris'), (SELECT channel_id FROM Channels WHERE channel_name = '#random'), 'Chris-hi'),
((SELECT user_id FROM Users WHERE user_name = 'Alice'), (SELECT channel_id FROM Channels WHERE channel_name = '#general'), 'General-!'),
((SELECT user_id FROM Users WHERE user_name = 'Bob'), (SELECT channel_id FROM Channels WHERE channel_name = '#general'), 'Bob-hrello'),
((SELECT user_id FROM Users WHERE user_name = 'Alice'), (SELECT channel_id FROM Channels WHERE channel_name = '#random'), 'Alice#random'),
((SELECT user_id FROM Users WHERE user_name = 'Chris'), (SELECT channel_id FROM Channels WHERE channel_name = '#random'), 'Chris-hello');


select * from messages;

-- List all organization names.
select organization_name from organizations;

-- List all channel names.
select channel_name from Channels;

-- List all channels in a specific organization by organization name.
select channel_name from Channels
left join organizations 
on Channels.organization_id = organizations.organization_id
where organization_name = 'Lambda School';

-- List all messages in a specific channel by channel name #general in order of post_time,  
-- descending. (Hint: ORDER BY. Because your INSERTs might have all taken place at the exact same time,
-- this might not return meaningful results. But humor us with the ORDER BY anyway.)


select * from messages
join Channels
on messages.message_channel_id = Channels.channel_id
where channel_name = '#general'
order by post_time desc;

-- List all channels to which user Alice belongs.

select * from Channels
join channel_subscription
on Channels.channel_id = channel_subscription.sub_channel_id
JOIN Users on channel_subscription.sub_user_id = Users.user_id
where Users.user_name = 'Alice';

-- List all messages in all channels by user Alice
select content,message_user_id from messages
join Channels
on messages.message_channel_id = Channels.channel_id
JOIN Users on Users.user_id = messages.message_user_id
join organizations on Channels.organization_id = organizations.organization_id 
where Users.user_name = 'Alice';

-- List all messages in #random by user Bob.
SELECT *  
FROM messages
JOIN Channels ON messages.message_channel_id = Channels.channel_id
JOIN Users ON Users.user_id = messages.message_user_id 
WHERE Users.user_name = 'Bob' AND Channels.channel_name = '#random';


-- list the count of messages across all channels per user. (Hint: COUNT, GROUP BY.)
-- The title of the user's name column should be User Name and the title of the count column should be Message Count.
--  (The SQLite commands .mode column and .header on might be useful here.)
-- The user names should be listed in reverse alphabetical order.

select Users.user_name as "User Name", count(content) as "Message Count" from messages
JOIN Users
on messages.message_user_id = Users.user_id
group by Users.user_name order by Users.user_name  desc;

--  List the count of messages per user per channel.

select Users.user_name as "User",Channels.channel_name as Channel, count(content) as "Message Count" from messages
JOIN Users
on messages.message_user_id = Users.user_id
join Channels
ON messages.message_channel_id = Channels.channel_id
GROUP BY Users.user_name, Channels.channel_name
ORDER BY Users.user_name ASC, Channels.channel_name ASC;


