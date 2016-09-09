@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-8 col-md-offset-2">
            <div class="panel panel-default">
                <div class="panel-heading">Login</div>
                <div class="panel-body">
                    <form class="form-horizontal" role="form" method="POST" action="{{ url('/login') }}">
                        {{ csrf_field() }}


                        <div class="form-group">
                            <label for="mail" class="col-md-4 control-label">Login type</label>

                            <div class="col-md-6">
                                <div class="btn-group btn-group-login" role="group" aria-label="Login">
                                    <button type="button" data-rel="user" class="btn btn-default btn-primary">Username</button>
                                    <button type="button" data-rel="mail" class="btn btn-default">Email</button>
                                </div>
                            </div>
                        </div>


                        <input type="hidden" name="loginType" id="loginType" value="user" />
                        <div class="form-group frm-login frm-login-mail{{ $errors->has('mail') ? ' has-error' : '' }}" style="display:none">
                            <label for="mail" class="col-md-4 control-label">E-Mail Address</label>

                            <div class="col-md-6">
                                <input id="mail" type="email" class="form-control" name="mail" value="{{ old('mail') }}"  autofocus>

                                @if ($errors->has('mail'))
                                    <span class="help-block">
                                        <strong>{{ $errors->first('mail') }}</strong>
                                    </span>
                                @endif
                            </div>
                        </div>

                        <div class="form-group frm-login frm-login-user{{ $errors->has('mail') ? ' has-error' : '' }}">
                            <label for="user" class="col-md-4 control-label">Username</label>

                            <div class="col-md-6">
                                <input id="user" type="text" class="form-control" name="user" value="{{ old('user') }}"  >

                                @if ($errors->has('user'))
                                    <span class="help-block">
                                        <strong>{{ $errors->first('user') }}</strong>
                                    </span>
                                @endif
                            </div>
                        </div>

                        <div class="form-group{{ $errors->has('password') ? ' has-error' : '' }}">
                            <label for="password" class="col-md-4 control-label">Password</label>

                            <div class="col-md-6">
                                <input id="password" type="password" class="form-control" name="password" required>

                                @if ($errors->has('password'))
                                    <span class="help-block">
                                        <strong>{{ $errors->first('password') }}</strong>
                                    </span>
                                @endif
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-6 col-md-offset-4">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" name="remember"> Remember Me
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-md-8 col-md-offset-4">
                                <button type="submit" class="btn btn-primary">
                                    Login
                                </button>

                                <a class="btn btn-link" href="{{ url('/password/reset') }}">
                                    Forgot Your Password?
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
