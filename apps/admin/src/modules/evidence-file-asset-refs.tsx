type EvidenceFileAssetRefsProps = {
  ids?: string[] | null;
  title?: string;
};

export function EvidenceFileAssetRefs({
  ids,
  title = '证据 FileAsset 只读追踪'
}: EvidenceFileAssetRefsProps) {
  const normalized = [...new Set((ids ?? []).map((item) => item.trim()).filter(Boolean))];

  return (
    <div className="action-card">
      <div>
        <p className="eyebrow">FileAsset / Evidence</p>
        <h2>{title}</h2>
      </div>
      <div className="notice">
        当前仅展示 Server 返回的 FileAsset ID 引用，不提供文件管理、删除、替换或业务状态修改。
      </div>
      {normalized.length ? (
        <pre className="json-panel">
          {JSON.stringify({ evidenceFileAssetIds: normalized }, null, 2)}
        </pre>
      ) : (
        <div className="empty-card">当前记录没有服务端返回的证据 FileAsset ID。</div>
      )}
    </div>
  );
}
