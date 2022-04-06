# News Apps Case Study
![](https://github.com/IhwanID/news-app-case-study/workflows/CI/badge.svg)

## BDD Specs

### Story: Customer requests to see their trending news

### Narrative #1

```
As an online customer
I want the app to automatically load my trending news
So I can always enjoy the trendong news
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to see their news
Then the app should display the trending news from remote
And replace the cache with the new news
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my latest news
So I can always enjoy news
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
And there’s a cached version of the news
And the cache is less than seven days old
When the customer requests to see the news
Then the app should display the latest news saved

Given the customer doesn't have connectivity
And there’s a cached version of the news
And the cache is seven days old or more
When the customer requests to see the news
Then the app should display an error message

Given the customer doesn't have connectivity
And the cache is empty
When the customer requests to see the news
Then the app should display an error message
```
