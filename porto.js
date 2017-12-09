// Observers de funcionarios

for (var i = 1; i <= 2; i++) {

    bms.observe('formula', {
        selector: "#user_" + i,
        formulas: ["funcionarios"],
        translate: true,
        trigger: function (origin, res) {
            if (res[0].length > 0) {
                var number = origin.attr('id').split('_')[1];

                res[0].forEach(function (funcionario) {
                    var funcionarioNumber = funcionario.slice(-1);

                    if (number == funcionarioNumber) {
                        origin.attr("xlink:href", "user.png");
                        origin.attr("data-user", res[0]);
                    }
                });
            }
        }
    });

    bms.observe('formula', {
        selector: "#user_" + i,
        formulas: ["administrador"],
        translate: true,
        trigger: function (origin, res) {
            if (res[0].length > 0) {
                var number = origin.attr('id').split('_')[1];

                res[0].forEach(function (funcionario) {
                    var funcionarioNumber = funcionario[0].slice(-1);

                    if (number == funcionarioNumber) {
                        if (funcionario[1] == true) {
                            origin.attr("xlink:href", "admin.png");
                        } else {
                            origin.attr("xlink:href", "user.png");
                        }
                    }
                });
            }
        }
    });
}

// Observers de Navios

for (var i = 1; i <= 2; i++) {
    bms.observe('formula', {
        selector: "#ship_" + i,
        formulas: ["navios"],
        translate: true,
        trigger: function (origin, res) {
            var number = origin.attr('id').split('_')[1];
            var fuiRemovido = true;

            res[0].forEach(function (navio) {
                var navioNumber = navio.slice(-1);

                if (number == navioNumber) {
                    fuiRemovido = false;
                    if (number == 1) {
                        origin.attr("x", '339.5');
                        origin.attr("y", '52.5');
                    } else {
                        origin.attr("x", '340.5');
                        origin.attr("y", '300.5');
                    }
                    origin.attr("data-ship", res[0]);
                }
            });

            if (fuiRemovido) {
                if (number == 1) {
                    origin.attr("x", '37.5');
                    origin.attr("y", '107.5');
                } else {
                    origin.attr("x", '37.5');
                    origin.attr("y", '290.5');
                }
            }
        }
    });

    bms.observe('formula', {
        selector: "#status_" + i,
        formulas: ["navios"],
        translate: true,
        trigger: function (origin, res) {
            var number = origin.attr('id').split('_')[1];
            var fuiRemovido = true;

            res[0].forEach(function (navio) {
                var navioNumber = navio.slice(-1);

                if (number == navioNumber) {
                    fuiRemovido = false;
                    origin.attr("visibility", 'visible');
                }
            });

            if (fuiRemovido) {
                origin.attr("visibility", 'hidden');
            }
        }
    });


    bms.observe('formula', {
        selector: "#status_" + i,
        formulas: ["navioContainer"],
        translate: true,
        trigger: function (origin, res) {
            var number = origin.attr('id').split('_')[1];

            res[0].forEach(function (registros) {
                var navioNumber = registros[0].slice(-1);

                if (navioNumber == number) {
                    var total = 0;
                    var auditados = 0;
                    var retirados = 0;

                    registros[1].forEach(function (containerh) {
                        total++;
                        if (containerh.status.value == "auditado") {
                            auditados++;
                        }
                        if (containerh.status.value == "retirado") {
                            retirados++;
                        }
                    });

                    if (auditados == total) {
                        origin.attr("xlink:href", "auditado.png");
                    } else if (retirados == total) {
                        origin.attr("xlink:href", "liberado.png");
                    }
                }

            });
        }
    });
}

// Observers de containers
var containersN1 = [];
var containersON1 = [];
var containersN2 = [];
var containersON2 = [];
for (var i = 1; i <= 4; i++) {
    bms.observe('formula', {
        selector: "#container_" + i,
        formulas: ["navioContainer"],
        translate: true,
        trigger: function (origin, res) {
            var number = origin.attr('id').split('_')[1];

            res[0].forEach(function (registros) {
                var navioNumber = registros[0].slice(-1);

                registros[1].forEach(function(container) {
                    var containerNumber = container.registro.value.slice(-1);
                    var containerStatus = container.status.value;

                    if (number < 3 && navioNumber == 1) {
                        if (containersON1.indexOf(container.registro.value) == -1 && containersN1.indexOf(number) == -1 && containersN1.length < registros[1].length) {
                            containersN1.push(number);
                            containersON1.push(container.registro.value);
                            origin.attr("visibility", "visible");
                            origin.attr("navioNumber", navioNumber);
                            origin.attr("containerId", JSON.stringify(container));
                        }
                    }

                    if (number > 2 && navioNumber == 2) {
                        if (containersON2.indexOf(container.registro.value) == -1 && containersN2.indexOf(number) == -1 && containersN2.length < registros[1].length) {
                            containersN2.push(number);
                            containersON2.push(container.registro.value);
                            origin.attr("visibility", "visible");
                            origin.attr("navioNumber", navioNumber);
                            origin.attr("containerId", JSON.stringify(container));
                        }
                    }
                });
            });

            var fuiRemovido = true;

            if (origin.attr("containerId")) {
                var containerInOrigin = JSON.parse(origin.attr("containerId"));

                res[0].forEach(function (registros) {
                    registros[1].forEach(function (containerh) {
                        if (containerInOrigin.registro.value == containerh.registro.value) {
                            if (containerh.status.value != "retirado") {
                                fuiRemovido = false;
                            }
                        }
                    });
                });

                if (fuiRemovido) {
                    origin.attr("visibility", "hidden");
                    origin.attr("containerId", null);

                    if (origin.attr("navioNumber") == 1) {
                        var index = containersN1.indexOf(number);
                        containersN1.splice(index, 1);

                        var index2 = containersON1.indexOf(number);
                        containersON1.splice(index2, 1);
                    } else {
                        var index = containersN2.indexOf(number);
                        containersN2.splice(index, 1);

                        var index2 = containersON2.indexOf(number);
                        containersON2.splice(index2, 1);
                    }
                    origin.attr("navioNumber", null);
                }
            }
        }
    });
}
