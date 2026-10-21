package model;

/**
 * アイコン画像1枚分(画像の種類 + 画像データ)。
 * IconServlet が、ブラウザに画像を返すときに使う。
 */
public class UserIcon {
    private final String contentType; // 例: image/png
    private final byte[] data;

    public UserIcon(String contentType, byte[] data) {
        this.contentType = contentType;
        this.data = data;
    }

    public String getContentType() { return contentType; }
    public byte[] getData() { return data; }
}