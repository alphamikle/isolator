# Isolator v2

## Details

This package was created to give you the easiest way to using isolates. You can use this package at any platform and on the Web too, but in the Web environment it will work in supporting mode - all your Backends will be placed in the same pool and the real profit of this package will not been gotten. In other words - your code will be worked in the web too.

## Concepts

There are two main concepts:

- Frontend
- Backend

### Frontend

Frontend is a lightweight mixin, which will be placed in your app's main isolate. Frontend is allowed to get messages from Backend and to run Backend's actions. You can use Frontend with any state management solution:

- ChangeNotifier
- MobX
- BloC
- Any other

To see, how it will work - open an example project.

Also, Frontend can be listened by any other entity - another Frontend, or your UI.

### Backend

Backend is an abstract class, which you need to extend for. Here will must be placed all your heavy logic and store the data. Of course - you can store all data, which you need in Frontend too, but, if you have a plans to handle a large amount of data in the app - you should place it in Backend. And handle it in the Backend too.

By default - Backend is a class, which will be alive as long, as your app will live. And by default - for every Backend will create a separate isolate. But you can place several Backends at the same isolate if you will be used poolId parameter of Isolator mechanism.

## Other

For more info and code examples, please - view the example project (still in development for now). There was placed several Frontends with ChangeNotifier and BloC and shown several types of using Backend too.

Tests folder contains the simplest implementations of Frontend and Backend variants.

## Schema of interaction

[![Schema](https://raw.githubusercontent.com/alphamikle/isolator/master/schema_v2.png)](https://raw.githubusercontent.com/alphamikle/isolator/master/schema_v2.png)

