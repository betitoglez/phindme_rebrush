/**
 * Created by Alberto on 08/09/2016.
 */
$(function(){

    /** Login Page **/

    //Login Group
    $(".btn-group-login > button").on("click",function(e){
            if ($(this).hasClass("btn-primary")){
                return;
            }
            var _rel = $(this).attr("data-rel");
            $(".frm-login-mail , .frm-login-user").hide();
            $(".frm-login-"+_rel).show();
            $("#loginType").val(_rel);
            $(this).addClass("btn-primary").siblings().removeClass("btn-primary");
    });
});
