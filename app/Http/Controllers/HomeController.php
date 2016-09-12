<?php

namespace App\Http\Controllers;

use App\Database\Register;
use App\Database\User;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $oUser = new User();
        $oUser->test();

        $oCheck = new Register();
        var_dump($oCheck->isValidMail("alberto"));
        var_dump($oCheck->isValidMail("alberto@dsds.es"));
        var_dump($oCheck->isValidMailExists("alberto@dsds.es"));
        var_dump($oCheck->isValidMailExists("betitoglez@gmail.com"));
        return view('home');
    }
}
