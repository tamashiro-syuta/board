$(function(){
    // jQueryの処理
    
    // ----------　モ　ー　ダ　ル　-----------
    $("#login-show").click(function () {
        $("#login-modal").fadeIn();
        console.log("a");
    });

    $("#signup-show").click(function () {
        $("#signup-modal").fadeIn();
        console.log("b");
    }); 

    $(".close-modal").click(function () {
        $("#login-modal").fadeOut();
        $("#signup-modal").fadeOut();
        $("#posts-modal").fadeOut();
        console.log("c");
    });

    $("#posts-show").click(function () {
        $("#posts-modal").fadeIn();
        console.log("a");
    });

});