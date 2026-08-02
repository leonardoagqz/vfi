"""
VFI - Validador Fiscal Inteligente
Modulo de Integracao IA

Suporte a multiplos provedores:
- OpenAI API
- Azure OpenAI Service
- Modo simulacao (offline)

Uso:
    python src/ia/vfi_ai.py --document-id 1 --provider openai
    python src/ia/vfi_ai.py --document-id 1 --provider azure
    python src/ia/vfi_ai.py --document-id 1 --simulate
"""

import os
import json
import argparse
import urllib.request
import urllib.error
from typing import Optional

SYSTEM_PROMPT = """Voce e um auditor fiscal experiente especializado em NF-e, CT-e e MDF-e.
Analise documentos fiscais e identifique anomalias, inconsistencias e riscos fiscais.
Classifique as anomalias como: CRITICO, ALERTA ou INFO.
Responda SEMPRE em formato JSON valido."""

def fetch_active_rules() -> list:
    fallback_rules = [
        "Inconsistencias nos valores calculados (ICMS, ST, IPI, PIS, COFINS)",
        "CFOP incompativel com NCM do produto",
        "Valores suspeitos ou fora do padrao de mercado",
        "Problemas de enquadramento fiscal (regime tributario)",
        "Divergencias entre XML e totais declarados",
        "Prazos de emissao fora do permitido"
    ]
    try:
        req = urllib.request.Request("http://localhost:5000/api/AiRules?activeOnly=true")
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return [
                f"{rule.get('description', '')} (Base Legal: {rule.get('referencia')})" if rule.get("referencia") else rule.get("description", "")
                for rule in data if rule.get("description")
            ]
    except Exception as e:
        print(f"[AVISO] Falha ao buscar regras da API ({e}). Usando regras fallback.")
        return fallback_rules

def build_prompt(document_id: int) -> str:
    rules = fetch_active_rules()
    rules_text = "\n".join([f"{i+1}. {rule}" for i, rule in enumerate(rules)])
    if not rules_text:
        rules_text = "1. Nenhuma regra ativa configurada."

    return f"""Analise fiscal do documento #{document_id}.

Identifique e classifique:
{rules_text}

Formato de resposta JSON esperado:
{{
    "documento_id": {document_id},
    "status": "CONFORME" | "ALERTA" | "IRREGULAR",
    "anomalias": [
        {{
            "tipo": "CRITICO|ALERTA|INFO",
            "codigo": "CODIGO_ERRO",
            "descricao": "Descricao detalhada",
            "campo_afetado": "campo no documento",
            "sugestao": "Acao recomendada"
        }}
    ],
    "confianca": 0.0 a 1.0,
    "recomendacao": "Resumo da recomendacao final"
}}"""

def call_openai(prompt: str, api_key: str, model: str = "gpt-4o-mini") -> dict:
    url = "https://api.openai.com/v1/chat/completions"
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.3,
        "max_tokens": 1000
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}: {e.reason}", "body": e.read().decode("utf-8")}

def call_azure(prompt: str, api_key: str, endpoint: str, deployment: str) -> dict:
    url = f"{endpoint}/openai/deployments/{deployment}/chat/completions?api-version=2024-02-15-preview"
    payload = {
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.3,
        "max_tokens": 1000
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={
        "Content-Type": "application/json",
        "api-key": api_key
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}: {e.reason}"}

def simulate_analysis(document_id: int) -> dict:
    return {
        "documento_id": document_id,
        "status": "SIMULADO",
        "anomalias": [
            {
                "tipo": "ALERTA",
                "codigo": "FIS-001",
                "descricao": "Valor total acima de R$ 50.000,00. Verificar enquadramento fiscal.",
                "campo_afetado": "TotalValue",
                "sugestao": "Revisar aliquota aplicavel e regime tributario do emitente."
            },
            {
                "tipo": "INFO",
                "codigo": "FIS-002",
                "descricao": "Documento dentro do prazo de emissao regular.",
                "campo_afetado": "IssueDate",
                "sugestao": "Nenhuma acao necessaria."
            }
        ],
        "confianca": 0.85,
        "recomendacao": "Documento aparenta conformidade fiscal. Revisar valores elevados e CFOP."
    }

def main():
    parser = argparse.ArgumentParser(description="VFI - Analise Fiscal com IA")
    parser.add_argument("--document-id", type=int, required=True, help="ID do documento fiscal")
    parser.add_argument("--provider", choices=["openai", "azure"], default="openai")
    parser.add_argument("--simulate", action="store_true", help="Usar modo simulacao")
    parser.add_argument("--model", default="gpt-4o-mini", help="Modelo LLM a utilizar")
    parser.add_argument("--output", help="Arquivo JSON de saida")
    args = parser.parse_args()

    if args.simulate:
        result = simulate_analysis(args.document_id)
        print("[MODO SIMULACAO] Analise IA concluida.")
    else:
        prompt = build_prompt(args.document_id)
        api_key = os.getenv("VFI_AI_API_KEY", "")
        if not api_key:
            print("[ERRO] Variavel VFI_AI_API_KEY nao definida. Use --simulate ou defina a chave.")
            return 1

        if args.provider == "azure":
            endpoint = os.getenv("VFI_AZURE_ENDPOINT", "")
            deployment = os.getenv("VFI_AZURE_DEPLOYMENT", args.model)
            if not endpoint:
                print("[ERRO] Variavel VFI_AZURE_ENDPOINT nao definida.")
                return 1
            response = call_azure(prompt, api_key, endpoint, deployment)
        else:
            response = call_openai(prompt, api_key, args.model)

        if "error" in response:
            print(f"[ERRO] Falha na chamada IA: {response['error']}")
            result = simulate_analysis(args.document_id)
            result["status"] = "FALLBACK_SIMULADO"
        else:
            content = response["choices"][0]["message"]["content"]
            try:
                result = json.loads(content)
            except json.JSONDecodeError:
                result = {
                    "documento_id": args.document_id,
                    "status": "PARSE_ERROR",
                    "anomalias": [],
                    "confianca": 0,
                    "recomendacao": "Falha ao interpretar resposta da IA.",
                    "resposta_bruta": content
                }
            result["tokens_usados"] = response.get("usage", {}).get("total_tokens", 0)
            print(f"[IA] Tokens usados: {result.get('tokens_usados', 'N/A')}")

    output = json.dumps(result, indent=2, ensure_ascii=False)
    print(output)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"\nResultado salvo em: {args.output}")

    return 0

if __name__ == "__main__":
    exit(main())
