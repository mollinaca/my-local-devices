#!/bin/bash

# データがあるルートディレクトリのパス
data_root="/path/to/your/music/files"

# 出力先のルートディレクトリ
output_root="/path/to/output/directory"

# F01, F02, ... のディレクトリを検索
find "${data_root}" -mindepth 1 -maxdepth 1 -type d -name 'F*' | sort | while read -r subdir; do
    # ディレクトリ名（F01, F02, ...）を取得
    dir_name=$(basename "${subdir}")

    echo "処理中: ${dir_name}"

    # ディレクトリ内の mp4 と m4a ファイルに対してループ
    find "${subdir}" -type f \( -iname "*.mp4" -o -iname "*.m4a" \) | sort | while read -r file; do
        # exiftool で必要な情報を取得
        artist=$(exiftool -artist -s -s -s "${file}")
        album=$(exiftool -album -s -s -s "${file}")
        title=$(exiftool -title -s -s -s "${file}")
        compilation=$(exiftool -compilation -s -s -s "${file}")

        # 曲順を取得
        track_number_raw=$(exiftool -tracknumber -s -s -s "${file}")

        # 曲順が取得できた場合
        if [[ -n "${track_number_raw}" ]]; then
            # 曲順が "4 of 16" のような形式の場合、有効な数字部分を抽出する
            if [[ "${track_number_raw}" =~ ([0-9]+) ]]; then
                track_number=${BASH_REMATCH[1]}
            else
                # 曲順が取得できない場合はエラーを出力してスキップ
                echo "エラー: 曲順が無効です - ファイル名: ${file}"
                continue
            fi

            # 曲順を二桁の数字に整形
            if [[ "${track_number}" =~ ^[0-9]+$ ]]; then
                track_number_padded=$(printf "%02d" "${track_number}")
            else
                echo "エラー: 曲順が無効です - ファイル名: ${file}"
                continue  # 次のファイルを処理する
            fi

            # Title に含まれる / を - に置換する
            title_filename=$(echo "${title}" | sed 's/\//-/g')

            # アーティスト名、アルバム名にスペースを含む場合に対処
            artist_dir=$(echo "${artist}" | sed 's/[[:space:]]/_/g')
            album_dir=$(echo "${album}" | sed 's/[[:space:]]/_/g')

            # 出力先ディレクトリを決定
            if [ "${compilation}" = "Yes" ]; then
                output_dir="${output_root}/Compilation/${album_dir}"
                output_file="${output_dir}/${track_number_padded}_${title_filename}.${file##*.}"
            else
                output_dir="${output_root}/${artist_dir}/${album_dir}"
                output_file="${output_dir}/${track_number_padded}_${title_filename}.${file##*.}"
            fi
        else
            # 曲順が取得できない場合
            # Title に含まれる / を - に置換する
            title_filename=$(echo "${title}" | sed 's/\//-/g')

            # アーティスト名、アルバム名にスペースを含む場合に対処
            artist_dir=$(echo "${artist}" | sed 's/[[:space:]]/_/g')
            album_dir=$(echo "${album}" | sed 's/[[:space:]]/_/g')

            # 出力先ディレクトリを決定
            if [ "${compilation}" = "Yes" ]; then
                output_dir="${output_root}/Compilation/${album_dir}"
                output_file="${output_dir}/${title_filename}.${file##*.}"
            else
                output_dir="${output_root}/${artist_dir}/${album_dir}"
                output_file="${output_dir}/${title_filename}.${file##*.}"
            fi
        fi

        # 出力先ディレクトリが存在しなければ作成する
        mkdir -p "${output_dir}"

        # ファイルをコピーする
        cp "${file}" "${output_file}"
    done

    echo "完了: ${dir_name}"
done

echo "処理が完了しました。"
