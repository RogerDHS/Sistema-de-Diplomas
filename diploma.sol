// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract RegistroDeDiploma {

    struct Diploma {
        string Nome;
        string Data;
        string Empresa;
        string curso;
    }

    // Login: adm Senha:123
    bytes32 private constant Login = keccak256(abi.encodePacked("adm"));
    bytes32 private constant Senha = keccak256(abi.encodePacked("123"));

    // Controle de login do administrador
    mapping(address => bool) private logado;

    // Diplomas por CPF hash
    mapping(bytes32 => Diploma[]) private diplomas;

    // CPF original (somente admin pode ver)
    mapping(bytes32 => string) private cpfOriginal;

    event LogIn(address user);
    event Deslogado(address user);
    event DiplomaAdd(bytes32 cpfHash, string Nome, string Empresa);
    event DiplomaAtt(bytes32 cpfHash, uint index);

    // ----------------------------------------------------------------------
    // 🔹 FUNÇÃO PÚBLICA PARA GERAR HASH DO CPF
    // ----------------------------------------------------------------------
    function gerarHashCPF(string calldata cpf) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(cpf));
    }

    // ----------------------------------------------------------------------
    // LOGIN / LOGOUT
    // ----------------------------------------------------------------------
    function login(string calldata loginName, string calldata password) external {
        require(keccak256(abi.encodePacked(loginName)) == Login, "Login incorreto");
        require(keccak256(abi.encodePacked(password)) == Senha, "Senha incorreta");

        logado[msg.sender] = true;
        emit LogIn(msg.sender);
    }

    function logout() external {
        logado[msg.sender] = false;
        emit Deslogado(msg.sender);
    }

    modifier SoLogado() {
        require(logado[msg.sender], "Voce nao esta logado como administrador");
        _;
    }
 
    // ADM: ADICIONAR DIPLOMA
    
    function addDiploma(
        bytes32 cpfHash,
        string calldata cpfOriginalTexto,
        string calldata Nome,
        string calldata Data,
        string calldata Empresa,
        string calldata curso
    ) external SoLogado 
    {
        if (bytes(cpfOriginal[cpfHash]).length == 0) {
            cpfOriginal[cpfHash] = cpfOriginalTexto;
        }

        diplomas[cpfHash].push(
            Diploma(Nome, Data, Empresa, curso)
        );

        emit DiplomaAdd(cpfHash, Nome, Empresa);
    }

    // ----------------------------------------------------------------------
    // ADMIN: VER CPF ORIGINAL
    // ----------------------------------------------------------------------
    function verCpfOriginal(bytes32 cpfHash)
        external
        view
        SoLogado
        returns (string memory)
    {
        return cpfOriginal[cpfHash];
    }

    // ADM: ATUALIZAR DIPLOMA

    function updateDiploma(
        bytes32 cpfHash,
        uint index,
        string calldata Nome,
        string calldata Data,
        string calldata Empresa,
        string calldata curso
    ) external SoLogado
    {
        require(index < diplomas[cpfHash].length, "Indice invalido");

        diplomas[cpfHash][index] = Diploma(
            Nome,
            Data,
            Empresa,
            curso
        );

        emit DiplomaAtt(cpfHash, index);
    }

    // CONSULTA PUBLICA

    function consultarDiplomasPublico(bytes32 cpfHash)
        external
        view
        returns (Diploma[] memory)
    {
        return diplomas[cpfHash];
    }

    function contarDiplomas(bytes32 cpfHash)
        external
        view
        returns (uint)
    {
        return diplomas[cpfHash].length;
    }
}
