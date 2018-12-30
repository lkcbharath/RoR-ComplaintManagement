function changeHandler() {
    var complaint_title = $("#complaint_title").val();
    var user_name = $("#user_name").val();
    if (complaint_title || user_name ){
        $("input[type=submit]").removeAttr("disabled");
    } else {
        $("input[type=submit]").attr("disabled", "disabled");
    }
}
