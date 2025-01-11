package org.fileflow.fileflow_app

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import android.util.Log

const val MIME_TYPE_DIR = "vnd.android.document/directory"  // MIME type for directories

/**
 * FastDocumentFile is a class that represents a file or directory within the document storage system.
 * It retrieves all relevant fields at once, offering a faster alternative to AndroidX/DocumentFile.
 */
class FastDocumentFile(
    private val context: Context,  // Context for accessing content resolver
    private val mime: String,  // MIME type of the document
    val uri: Uri,  // URI of the document
    val name: String,  // Name of the document
    val size: Long,  // Size of the document
    val lastModified: Long,  // Last modified timestamp of the document
) {
    val isDirectory: Boolean = mime == MIME_TYPE_DIR  // Checks if it's a directory
    val isFile: Boolean = !isDirectory && mime.isNotBlank()  // Checks if it's a file

    /**
     * Retrieves the list of files (children) of this document if it's a directory.
     * 
     * @return List of FastDocumentFile representing the files within the directory.
     */
    fun listFiles(): List<FastDocumentFile> {
        val resolver: ContentResolver = context.contentResolver  // Access content resolver for querying
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
            uri,
            DocumentsContract.getDocumentId(uri)  // Get the document ID to build the URI for child documents
        )

        val results = mutableListOf<FastDocumentFile>()

        var cursor: Cursor? = null
        try {
            // Query for child documents (files)
            cursor = resolver.query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_MIME_TYPE,  // MIME type of the child document
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,  // Document ID
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,  // Display name
                    DocumentsContract.Document.COLUMN_SIZE,  // Size of the document
                    DocumentsContract.Document.COLUMN_LAST_MODIFIED,  // Last modified time
                ),
                null,
                null,
                null
            )
            // Iterate over the results and add them to the list
            while (cursor!!.moveToNext()) {
                results.add(
                    FastDocumentFile(
                        context = context,
                        mime = cursor.getString(0),
                        uri = DocumentsContract.buildDocumentUriUsingTree(
                            uri,
                            cursor.getString(1)  // Build the URI for the document using its ID
                        ),
                        name = cursor.getString(2),
                        size = cursor.getLong(3),
                        lastModified = cursor.getLong(4)
                    )
                )
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error: $e")  // Log any error encountered during query
        } finally {
            try {
                cursor?.close()  // Close the cursor to avoid memory leaks
            } catch (_: Exception) {}
        }
        return results  // Return the list of files
    }

    companion object {
        const val TAG = "FastDocumentFile"  // Tag for logging

        /**
         * Creates a FastDocumentFile instance from a tree Uri.
         * 
         * @param context The context of the application
         * @param treeUri The URI representing the root of the tree
         * @return A FastDocumentFile representing the tree
         */
        fun fromTreeUri(context: Context, treeUri: Uri): FastDocumentFile {
            val documentId = when {
                DocumentsContract.isDocumentUri(
                    context,
                    treeUri  // Check if the URI is a document URI
                ) -> DocumentsContract.getDocumentId(treeUri)
                else -> DocumentsContract.getTreeDocumentId(treeUri)  // Get the tree document ID
            }

            // Build and return the FastDocumentFile for the tree
            return FastDocumentFile(
                context = context,
                mime = "",
                uri = DocumentsContract.buildDocumentUriUsingTree(
                    treeUri,
                    documentId,
                ),
                name = "",
                size = 0,
                lastModified = 0,
            )
        }

        /**
         * Creates a FastDocumentFile instance from a document URI.
         * 
         * @param context The context of the application
         * @param documentUri The URI of the document
         * @return A FastDocumentFile representing the document or null if it couldn't be retrieved
         */
        fun fromDocumentUri(context: Context, documentUri: Uri): FastDocumentFile? {
            var cursor: Cursor? = null
            try {
                // Query the document for its properties
                cursor = context.contentResolver.query(
                    documentUri,
                    arrayOf(
                        DocumentsContract.Document.COLUMN_MIME_TYPE,  // MIME type
                        DocumentsContract.Document.COLUMN_DISPLAY_NAME,  // Display name
                        DocumentsContract.Document.COLUMN_SIZE,  // Size
                        DocumentsContract.Document.COLUMN_LAST_MODIFIED,  // Last modified time
                    ),
                    null,
                    null,
                    null
                )

                return if (cursor != null && cursor.moveToFirst()) {
                    // If a document is found, return a FastDocumentFile
                    FastDocumentFile(
                        context = context,
                        mime = cursor.getString(0),
                        uri = documentUri,
                        name = cursor.getString(1),
                        size = cursor.getLong(2),
                        lastModified = cursor.getLong(3),
                    )
                } else {
                    null  // Return null if no document is found
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error: $e")  // Log any error encountered
                return null  // Return null on error
            } finally {
                try {
                    cursor?.close()  // Close the cursor to avoid memory leaks
                } catch (_: Exception) {}
            }
        }
    }
}
