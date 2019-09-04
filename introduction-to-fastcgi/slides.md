---
title: "FastCGI"
subtitle: "Group 10"
---

## In the beginning

One app, one web server

```
apache.c:
    if (page == "/loginform.html") {
        sendfile("templates/loginform.html");
    } else if (page == "/profile.html") {
        printf("Status: 200 OK\r\n");
        printf("Content-type: text/html\r\n");
        printf("\r\n");
        printf("<h1>Hello %s</h1>", user);
```

# In the evening

- Eat spaghetti
- Drink wine

# Conclusion

- And the answer is...
