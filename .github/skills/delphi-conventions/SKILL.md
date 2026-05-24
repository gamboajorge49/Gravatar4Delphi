---
name: delphi-conventions
description: >
  Aplica convenções globais de programação Delphi a qualquer código gerado ou revisado.
  Use sempre que o usuário pedir para escrever, revisar, refatorar ou melhorar código Delphi.
  Também acione quando o usuário mencionar: "boas práticas", "padrão de código", "convenções",
  "code review", "como devo escrever", "está correto esse código", "pode melhorar", ou qualquer
  pedido de geração de código Delphi — mesmo que não cite explicitamente as convenções.
  Esta skill é obrigatória para TODO código Delphi gerado neste projeto.
---

# Delphi Global Programming Conventions

## Ambiente Alvo
- **IDE principal**: Delphi 10.1 Berlin (compatibilidade mínima: Delphi Rio)
- **Banco**: SQL Server 2014 via FireDAC (ADO só se explicitamente solicitado)
- **Reporting**: FastReport 5.3.14
- **UI**: DevExpress VCL 15.2.2

---

## Formatação

```pascal
// CORRETO — sem espaço antes de :=, um espaço depois:
Version:= 1;
Nome:= 'Jorge';

// ERRADO:
Version := 1;
```

```pascal
// CORRETO — then em nova linha:
if Something
then DoSomething;

if Something
then DoSomething
else DoSomethingElse;

// ERRADO:
if Something then DoSomething;
```


When editing Delphi files (.pas, .dfm, .dpr, .dpk):

1. NEVER rewrite the entire file — use surgical edits (str_replace).
2. NEVER change the file encoding; preserve exactly the original encoding.
3. When reading the file, detect the current encoding (UTF-8 BOM, UTF-8, ANSI/Windows-1252) and ALWAYS write in the same encoding read.
4. Strings with accents (ã, é, ç, ó, etc.) must be preserved byte by byte, without normalization, escaping, or conversion.
5. When using bash to write content, use redirection that preserves the original encoding — never `echo` or `printf` directly into .pas files.
6. Prefer the `str_replace` command instead of recreating the file with `create_file`.
7. If you need to create a new .pas file, write in UTF-8 with BOM (add the BOM: bytes EF BB BF at the beginning).

---

## Liberação de Objetos

**Sempre use `FreeAndNil` — nunca `.Free` direto:**

```pascal
FreeAndNil(MyObject);
```

**Try-Finally para recursos:**

```pascal
var
  Stream: TFileStream;
  Reader: TStreamReader;
begin
  Stream:= nil;
  Reader:= nil;
  try
    Stream:= TFileStream.Create('file.txt', fmOpenRead);
    Reader:= TStreamReader.Create(Stream);
    // uso do reader
  finally
    FreeAndNil(Reader);
    FreeAndNil(Stream);
  end;
end;
```

---

## Estilo de Saída de Função

Prefira `EXIT(value)` a `Result + EXIT`:

```pascal
// CORRETO:
if NOT FLesson.AvailableShortQuestions
then EXIT(false);

// EVITAR:
if NOT FLesson.AvailableShortQuestions then
begin
  Result:= false;
  EXIT;
end;
```

---

## Verificações de Nil

Nunca use verificações silenciosas de nil quando o objeto não deveria ser nil:

```pascal
// ERRADO — esconde bugs:
if SomeObject = NIL then EXIT;

// CORRETO — falha explícita:
Assert(SomeObject <> NIL);
// ou:
if SomeObject = NIL
then raise Exception.Create('SomeObject não pode ser nil aqui');
```

---

## Properties e Boilerplate

**Evite properties sem lógica real no getter/setter:**

```pascal
// EVITAR se FAge é só leitura/escrita direta:
property Age: Integer read FAge write FAge;

// EVITAR delegation desnecessária se User é acessível:
function TLesson.getColor: TColor;
begin
  Result:= User.Color;
end;
```

Use fields diretamente quando não há lógica adicional.

---

## Tratamento de Exceções

**Use tipos específicos — nunca swallow silencioso:**

```pascal
// ERRADO — esconde problemas:
try
  RiskyOperation;
except
  // silêncio
end;

// CORRETO:
try
  RiskyOperation;
except
  on E: EFileNotFoundException do
    ShowMessage('Arquivo não encontrado: ' + E.Message);
  on E: EAccessViolation do
    ShowMessage('Violação de acesso: ' + E.Message);
  on E: Exception do
  begin
    // log do erro
    raise;
  end;
end;
```

---

## Conversões de String/Número

**Sempre use as variantes seguras:**

```pascal
var
  Valor: Integer;
  ValorF: Double;
begin
  if NOT TryStrToInt(EditCodigo.Text, Valor)
  then raise Exception.Create('Código inválido');

  if NOT TryStrToFloat(EditPreco.Text, ValorF)
  then raise Exception.Create('Preço inválido');
end;
```

---

## Construções Proibidas

| Proibido | Substituto |
|---|---|
| `absolute` | referências de variável diretas |
| Ponteiros brutos (`^`, `Ptr^`) | referências de objeto, arrays dinâmicos |
| `Application.ProcessMessages` | `TThread`, `TTask` |
| `with` | referências explícitas |
| `TFile` (unit antiga) | `TFileStream`, `TStreamReader/Writer` |
| Variáveis globais | injeção de dependência, DataModules |
| `initialization`/`finalization` | construtores/destrutores explícitos |

---

## Threads e Processamento Assíncrono

```pascal
// Thread anônima simples:
TThread.CreateAnonymousThread(
  procedure
  begin
    // trabalho em background
    TThread.Synchronize(nil,
      procedure
      begin
        Label1.Caption:= 'Concluído';
      end);
  end
).Start;

// Ou com TTask:
TTask.Run(
  procedure
  begin
    // trabalho em background
  end
);
```

---

## Generics

Use apenas quando:
- Segurança de tipo é crítica
- Múltiplas coleções fortemente tipadas são necessárias
- O padrão é genuinamente reutilizável entre vários tipos

**Evite generics quando alternativas mais simples existem** — aumentam significativamente o tamanho do binário e o tempo de compilação.

---

## Padrões de Qualidade (Zero Tolerância)

- ❌ Variáveis globais
- ❌ Hints e Warnings do compilador
- ❌ Exceções engolidas silenciosamente
- ❌ Memory leaks

---

## Operações de Arquivo

Prefira `TFileStream` / `TStreamReader` / `TStreamWriter` ao invés de `TFile`:

```pascal
var
  Stream: TFileStream;
begin
  Stream:= TFileStream.Create('dados.dat', fmOpenRead);
  try
    // leitura
  finally
    FreeAndNil(Stream);
  end;
end;
```

---

## Checklist Rápido ao Gerar Código

1. `FreeAndNil` em vez de `.Free`?
2. Try-Finally em recursos?
3. TryStrToInt/TryStrToFloat em conversões?
4. Sem `with`, sem `Application.ProcessMessages`, sem globais?
5. Exceções tratadas explicitamente?
6. Assert ou raise onde nil não é esperado?
