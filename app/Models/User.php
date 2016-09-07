<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

/**
 * Class User
 */
class User extends Authenticatable
{
    use Notifiable;
    protected $table = 'user';

    protected $primaryKey = 'id_User';

	public $timestamps = true;

    protected $fillable = [
        'user',
        'name',
        'name_privacy',
        'email',
        'mail_privacy',
        'privacy',
        'remember_token',
        'password',
        'is_active'
    ];

    protected $guarded = [];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

        
}