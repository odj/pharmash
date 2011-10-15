function updateOutput() {
    var inputValue = $("#inputValue").val();
    $.ajax({
        type: 'POST',
        url: '/convert',
        data: {
            inputValue: inputValue,
            inputFormat: $("#inputFormat").val(),
            outputFormat: $("#outputFormat").val()
        },
        success: function(data) {
            $("#outputValue").val(data);
        }
    });
}

function inputClicked() {
    var input = $("#inputValue");
    console.log(input.attr('defaultValue'));
    if (input.val() == input.attr('defaultValue')) {
      input.val('');
    }
}
