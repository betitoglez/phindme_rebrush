<?php

use \Illuminate\Http\Response;
use \Illuminate\Http\Request;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of the routes that are handled
| by your application. Just tell Laravel the URIs it should respond
| to using a Closure or controller method. Build something great!
|
*/

Route::get('/', function () {
    $locale = App::getLocale();
    return redirect("$locale/home");
});

/*
Route::get('response', function () {
    return 'Users!';
});
*/
Route::get('{locale}/home', function ($locale) {
    App::setLocale($locale);
    return redirect("/home");
});

Auth::routes();

Route::get('/home', 'HomeController@index');
