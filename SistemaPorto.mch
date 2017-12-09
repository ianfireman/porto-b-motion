/* SistemaPorto
 * Author: abhner
 * Creation date: 25/10/2017
 */
MACHINE
    SistemaPorto

SETS
    TIEM;//Conjunto dos navios cadastrados
    CONTAINERS_ID;//Containers cadastrados
    STATUS_CONTAINER = {recepcionado, auditado, retirado, encaminhado};
    CPF
CONSTANTS
    REG_NAVIO,
    REG_CONTAINER,
    CAPACIDADE_MAXIMA
PROPERTIES

    REG_NAVIO = struct(inscricao: TIEM, maxContainers: NATURAL)
    & CAPACIDADE_MAXIMA : NATURAL & CAPACIDADE_MAXIMA = 10
    & REG_CONTAINER = struct(registro: CONTAINERS_ID, status: STATUS_CONTAINER)
VARIABLES
    navioContainer,
    funcionarios,
    navios,
    capacidades,
    administrador,
    containers
INVARIANT
    navios: POW(TIEM)
    & containers: POW(CONTAINERS_ID)
    & funcionarios: POW(CPF) 
    & administrador : funcionarios --> BOOL
    & capacidades: navios --> NATURAL
    & 0 /: ran(capacidades) & ran(capacidades) <: 1..CAPACIDADE_MAXIMA
    & navioContainer: navios +-> POW(REG_CONTAINER)
    //Garantir que nao haja dois navios iguais
    & ! (cn1,cn2) . (
        (cn1 : dom(navioContainer) & cn2 : dom(navioContainer) & cn1 /= cn2)
        => navioContainer(cn1) /\ navioContainer(cn2) = {})
INITIALISATION
    navios := {}
    || capacidades := {}
    || administrador := {}
    || funcionarios := {}
    || containers := {}
    || navioContainer := {}
OPERATIONS
     /* ----------- usuários ----------- */
    
    cadastrarFuncionario(func) =
        PRE
            func : CPF & func /: funcionarios
        THEN
            //cadastra funcionario sem privilegios
            funcionarios := funcionarios \/ {func}
            || administrador := administrador \/ { (func,FALSE) }
        END;
        
        //metodo para dar privilegio de administrador
        atualizarPrivilegio(func,valor) =
        PRE
            func : CPF & func : funcionarios &
            valor : BOOL &
            administrador(func) /= valor
        THEN
            administrador := administrador <+ { (func,valor) }
        END;
    
    /* ----------- navios ----------- */
    
    cadastrarNavio(func, tiem, capacidade) =        
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & tiem : TIEM & tiem /: navios
            & capacidade : NATURAL & capacidade > 0 & capacidade < CAPACIDADE_MAXIMA
        THEN
            navios := navios \/ {tiem}
            || capacidades := capacidades \/ { (tiem, capacidade) }
        END;
        
    removerNavio(func, tiem) =
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & tiem : TIEM & tiem : navios
        THEN
            navios := navios - {tiem}
            || capacidades := {tiem} <<| capacidades
        END;
        
    /* ----------- containers ----------- */
    
    cadastrarContainer(func, reg, tiem, stat) =        
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & tiem : TIEM & tiem : navios
            & reg : CONTAINERS_ID & reg /: containers
            & stat : STATUS_CONTAINER & stat = recepcionado
        THEN
            containers := containers \/ {reg}
            ||
            //cadastra o container e associa a um navio
            // cada navio estará associado a um conjunto de containers
            IF tiem : dom(navioContainer) THEN
                navioContainer := navioContainer 
                <+ {(tiem, navioContainer(tiem) \/ {rec(registro:reg, status:stat)})}
            ELSE
                navioContainer := navioContainer \/ {tiem |-> {rec(registro:reg, status:stat)}}
            END
        END;
        
    retirarContainer(func, reg) =
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & reg : REG_CONTAINER & reg'registro : containers & reg'status = recepcionado
            
        THEN
            //remove o container do navio, se nao haver container no navio então exclui ele também
            ANY tiem WHERE
                tiem : dom(navioContainer) &
                tiem : {num | num : TIEM & num : dom(navioContainer) & 
                    # num2 . (num2: REG_CONTAINER & num2 : navioContainer(num) 
                        & num2'registro = reg'registro)}
            THEN
                containers := containers - {reg'registro}
                ||
                IF card(navioContainer(tiem)) = 1 THEN
                    navioContainer := {tiem} <<| navioContainer
                ELSE
                    navioContainer(tiem) := navioContainer(tiem) 
                    - {reg2 | reg2: REG_CONTAINER & reg2 : navioContainer(tiem) & reg2'registro = reg'registro}
                END
            END
        END;
        
        //atualiza o status do container para auditado
     setAuditado(func, tiem, reg) =
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & tiem : navios & tiem : dom(navioContainer)
            & reg : REG_CONTAINER & reg : navioContainer(tiem) & reg'status = recepcionado
        THEN
            navioContainer(tiem) := (navioContainer(tiem) - {reg2 | reg2: REG_CONTAINER & reg2 : navioContainer(tiem) & reg2'registro = reg'registro})
           \/ {rec(registro:reg'registro, status:auditado)}    
        END;
        
        //atualiza o status do container para retirado 
     setRetirado(func, tiem, reg) =
        PRE
            func : CPF & func : funcionarios & administrador(func) = TRUE
            & tiem : navios & tiem : dom(navioContainer)
            & reg : REG_CONTAINER & reg : navioContainer(tiem) & reg'status = auditado
        THEN
            navioContainer(tiem) := (navioContainer(tiem) - {reg2 | reg2: REG_CONTAINER & reg2 : navioContainer(tiem) & reg2'registro = reg'registro})
           \/ {rec(registro:reg'registro, status:retirado)}    
        END;

        
        //libera o navio somente se todos os containers estiverem com status de retirado
        liberarNavio(func, tiem) =
            PRE
                func : CPF & func : funcionarios & administrador(func) = TRUE
                & tiem : navios & tiem : dom(navioContainer)
                & ! reg . (reg : REG_CONTAINER & reg : navioContainer(tiem)
                    => reg'status = retirado)
            THEN
                navioContainer := {tiem} <<| navioContainer
            END
END
