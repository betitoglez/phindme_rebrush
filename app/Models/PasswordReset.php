<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class PasswordReset
 */
class PasswordReset extends Model
{
    protected $table = 'password_resets';

    public $timestamps = true;

    protected $fillable = [
        'mail',
        'token'
    ];

    protected $guarded = [];

        
}