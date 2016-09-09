<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    protected $_defaultLoginField = "mail";

    /**
     * Where to redirect users after login / registration.
     *
     * @var string
     */
    protected $redirectTo = '/home';

    protected $oRequest;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(Request $oRequest)
    {
        $this->oRequest = $oRequest;
        $this->middleware('guest', ['except' => 'logout']);
    }


    /**
     * Get the login username to be used by the controller.
     *
     * @return string
     */
    public function username()
    {
        $oRequest = $this->oRequest;
        if ($oRequest->getMethod() == 'POST'
            && $oRequest->get("loginType","user") == "user"){
            $this->_defaultLoginField = "user";
        }
        return $this->_defaultLoginField;
    }


    /**
     * Get the needed authorization credentials from the request.
     *
     * Added 'is_active' flag by Alberto.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    protected function credentials(Request $request)
    {
        return array_merge($request->only($this->username(), 'password'),array("is_active"=>1));
    }



}
